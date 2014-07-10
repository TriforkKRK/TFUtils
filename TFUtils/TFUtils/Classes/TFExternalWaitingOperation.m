/*
 * Copyright (c) 2014 Krzysztof Profic
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

#import "TFExternalWaitingOperation.h"

@implementation TFExternalWaitingOperation

- (void)tf_setExternalOperationCompleted:(BOOL)completed
{
    @synchronized(self) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        _TFexecuting =  !completed;
        _TFfinished = completed;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    }
}

-(void)start
{
    if (self.isCancelled) {
        [self tf_setExternalOperationCompleted:YES];
        return;
    }
    
    [self tf_setExternalOperationCompleted:NO];
    
    // This is just a dummy wrapper which does nothing, the actual operation is performed somewhere else, thus
    // operation will be in "executing" state until someone calls kpSetOperationCompleted:YES
}

- (BOOL)isExecuting
{
    return _TFexecuting;
}

- (BOOL)isFinished
{
    return _TFfinished;
}

- (BOOL)isConcurrent
{
    return YES;
}

@end