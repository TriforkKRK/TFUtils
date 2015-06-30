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


#import "UIViewController+tf_appearanceNotifications.h"
#import <objc/runtime.h>

NSString * const UIViewControllerViewWillAppearNotification     = @"UIViewControllerViewWillAppearNotification";
NSString * const UIViewControllerViewDidAppearNotification      = @"UIViewControllerViewDidAppearNotification";
NSString * const UIViewControllerViewWillDisappearNotification  = @"UIViewControllerViewWillDisappearNotification";
NSString * const UIViewControllerViewDidDisappearNotification   = @"UIViewControllerViewDidDisappearNotification";
NSString * const UIViewControllerAppearanceNotificationAnimatedKey = @"animated";

NSString * const UIViewControllerBeginAppearanceTransitionNotification = @"UIViewControllerBeginAppearanceTransitionNotification";
NSString * const UIViewControllerEndAppearanceTransitionNotification = @"UIViewControllerEndAppearanceTransitionNotification";
NSString * const UIViewControllerAppearanceNotificationAppearingKey = @"isAppearing";

// Implementation is based on: http://nshipster.com/method-swizzling/

@implementation UIViewController (tf_appearanceNotifications)

#pragma mark - Overriden 

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(viewWillAppear:) withSelector:@selector(tf_viewWillAppear:)];
        [self swizzleSelector:@selector(viewDidAppear:) withSelector:@selector(tf_viewDidAppear:)];
        [self swizzleSelector:@selector(viewWillDisappear:) withSelector:@selector(tf_viewWillDisappear:)];
        [self swizzleSelector:@selector(viewDidDisappear:) withSelector:@selector(tf_viewDidDisappear:)];
        
        [self swizzleSelector:@selector(beginAppearanceTransition:animated:) withSelector:@selector(tf_beginAppearanceTransition:animated:)];
        [self swizzleSelector:@selector(endAppearanceTransition) withSelector:@selector(tf_endAppearanceTransition)];
    });
}

#pragma mark - Private Methods

+ (void)swizzleSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector
{
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Method Swizzling

- (void)tf_viewWillAppear:(BOOL)animated
{
    NSLog(@"[i] viewWillAppear (vc: %@)", self);
    [[NSNotificationCenter defaultCenter] postNotificationName:UIViewControllerViewWillAppearNotification object:self userInfo:@{UIViewControllerAppearanceNotificationAnimatedKey: @(animated)}];
    
    [self tf_viewWillAppear:animated];
}

- (void)tf_viewDidAppear:(BOOL)animated
{
    [self tf_viewDidAppear:animated];
    
    NSLog(@"[i] viewDidAppear (vc: %@)", self);
    [[NSNotificationCenter defaultCenter] postNotificationName:UIViewControllerViewDidAppearNotification object:self userInfo:@{UIViewControllerAppearanceNotificationAnimatedKey: @(animated)}];
}

- (void)tf_viewWillDisappear:(BOOL)animated
{
    NSLog(@"[i] viewWillDisappear (vc: %@)", self);
    [[NSNotificationCenter defaultCenter] postNotificationName:UIViewControllerViewWillDisappearNotification object:self userInfo:@{UIViewControllerAppearanceNotificationAnimatedKey: @(animated)}];
    
    [self tf_viewWillDisappear:animated];
}

- (void)tf_viewDidDisappear:(BOOL)animated
{
    [self tf_viewDidDisappear:animated];

    NSLog(@"[i] viewDidDisappear (vc: %@)", self);
    [[NSNotificationCenter defaultCenter] postNotificationName:UIViewControllerViewDidDisappearNotification object:self userInfo:@{UIViewControllerAppearanceNotificationAnimatedKey: @(animated)}];
}

- (void)tf_beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UIViewControllerBeginAppearanceTransitionNotification object:self userInfo:@{UIViewControllerAppearanceNotificationAnimatedKey: @(animated), UIViewControllerAppearanceNotificationAppearingKey: @(isAppearing)}];
    [self tf_beginAppearanceTransition:isAppearing animated:animated];
}

- (void)tf_endAppearanceTransition
{
    [self tf_endAppearanceTransition];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIViewControllerEndAppearanceTransitionNotification object:self];
}
@end
