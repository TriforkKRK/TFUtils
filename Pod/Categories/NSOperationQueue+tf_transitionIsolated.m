/*
 * Created by Krzysztof Profic on 19/09/2013.
 * Copyright (c) 2013 Trifork A/S.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "NSOperationQueue+tf_transitionIsolated.h"
#import "UIViewController+tf_appearanceNotifications.h"
#import "TFExternalWaitingOperation.h"

const NSString * kCategoryName = @"tf_transitionIsolated";

@interface NSOperationQueue (tf_transitionIsolatedPrivate)
+ (NSOperationQueue *)transitionOperationQueue;
+ (NSMapTable *)transitionOperationMapTable;    // uiviewcontroller -> transitionOperation

+ (NSHashTable *)isolatedOperationsTable;
@end

@implementation NSOperationQueue (tf_transitionIsolated)

#pragma mark - Overriden

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginAppearanceTransition:) name:UIViewControllerBeginAppearanceTransitionNotification object:nil];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndAppearanceTansition:) name:UIViewControllerEndAppearanceTransitionNotification object:nil];
        //  due to potential Apple Bug thah causes the endAppearanceTransition not to be callend on UINavigationController childViewControllers
        //  we have to use will/did appear callbacks - however this doeasn't cover the "cancel" scenario in interactive vc transtions, but works fine for non interactive.
        //  REFERENCE: https://devforums.apple.com/thread/225533?tstart=0
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginAppearanceTransition:) name:UIViewControllerViewWillAppearNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginAppearanceTransition:) name:UIViewControllerViewWillDisappearNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndAppearanceTansition:) name:UIViewControllerViewDidAppearNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndAppearanceTansition:) name:UIViewControllerViewDidDisappearNotification object:nil];
    });
}

#pragma mark - Interface Methods

- (void)addTransitionIsolatedOperation:(NSOperation *)op
{
    @synchronized([[self class] isolatedOperationsTable]) {
        NSArray * isolationOperations = [[[self class] transitionOperationQueue] operations];
        for (NSOperation * transitionIsolationOperation in isolationOperations) {
            [op addDependency:transitionIsolationOperation];
        }
        
        // store the reference to this operation in case of view controller transition being started before this one execution starts
        // @see +didBeginAppearanceTransition:
        // we don't have to remove these objects as they are stored internally as week pointers
        [[[self class] isolatedOperationsTable] addObject:op];
        [self addOperation:op];
        NSLog(@"[d] Added transition isolated operation: %@, stack size: %lu", op, (unsigned long)[[[self class] transitionOperationQueue] operationCount]);
    }
}

- (void)addTransitionIsolatedOperationWithBlock:(void (^)(void))block
{
    NSBlockOperation * blockOperationWrapper = [NSBlockOperation blockOperationWithBlock:block];
    [self addTransitionIsolatedOperation:blockOperationWrapper];
}

#pragma mark - Private Methods

+ (NSOperationQueue *)transitionOperationQueue
{
    static NSOperationQueue * q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = [[NSOperationQueue alloc] init];
        q.maxConcurrentOperationCount = NSIntegerMax;   // these operations are not expensive (noops) while we want them to be able to start as soon as possible
    });
    return q;
}

+ (NSMapTable *)transitionOperationMapTable
{
    static NSMapTable * table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = [NSMapTable strongToWeakObjectsMapTable];
    });
    return table;
}

+ (NSHashTable *)isolatedOperationsTable
{
    static NSHashTable * table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = [NSHashTable weakObjectsHashTable];
    });
    return table;
}

#pragma mark - Notifications

+ (void)didBeginAppearanceTransition:(NSNotification *)notification
{
    UIViewController * vc = notification.object;
    NSString * key = [@(vc.hash) description];
    
    @synchronized([self isolatedOperationsTable]) {
        if ([[self transitionOperationMapTable] objectForKey:key] != nil) {
            NSLog(@"[w] Transition operation already exists for view controller: %@. It may be because of unbalanced calls to begin/end appearance transition (eg. you're missing viewDidDissapear or viewWillAppear is called twice). Bypassing!", vc);
            return;
        }
        
        
        TFExternalWaitingOperation * transitionOperationWrapper = [[TFExternalWaitingOperation alloc] init];
        for (NSOperation * op in [[self isolatedOperationsTable] allObjects]) {
            if (op.isExecuting || op.isFinished || op.isCancelled) continue;
            
            [op addDependency:transitionOperationWrapper];
        }
        
        [[self transitionOperationMapTable] setObject:transitionOperationWrapper forKey:key];
        [[self transitionOperationQueue] addOperation:transitionOperationWrapper];
        NSLog(@"[d] Did begin transition, stack size: %lu", (unsigned long)[[[self class] transitionOperationQueue] operationCount]);
    }
}

+ (void)didEndAppearanceTansition:(NSNotification *)notification
{
    UIViewController * vc = notification.object;
    NSString * key = [@(vc.hash) description];
    
    @synchronized([self isolatedOperationsTable]) {
        TFExternalWaitingOperation * transitionOperation = [[self transitionOperationMapTable] objectForKey:key];
        if (transitionOperation == nil) {
            NSLog(@"[w] Transition operation not found for view controller: %@. It may be because of unbalanced calls to begin/end appearance transition (eg. you're missing viewWillAppear or viewDidDissapear is called twice). Bypassing!", vc);
            [[self transitionOperationMapTable] removeObjectForKey:key];
            return;
        }
        // it's possible that transitionOperation wrapper do not even start while we already get endAppearance - that is supposed to finish the operation,
        // thus, we have to check if this is the case and if it is then cancel this operation - it will still be have a state set to "finished"
        // at the end so the dependent operations will be released as usually.
        if (!transitionOperation.isExecuting && !transitionOperation.isCancelled) {
            [transitionOperation cancel];
        }
        else {
            // the line above completes the tansition operation wrapper releasing all transitionIsolated operations that were dependent on this transition
            [transitionOperation tf_setExternalOperationCompleted:YES];
        }
        
        [[self transitionOperationMapTable] removeObjectForKey:key];
        NSLog(@"[d] Did end transition, stack size: %lu", (unsigned long)[[[self class] transitionOperationQueue] operationCount]);
    }
}

@end
