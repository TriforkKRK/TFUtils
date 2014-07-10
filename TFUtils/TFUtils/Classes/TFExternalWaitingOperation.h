/*
 * Created by Krzysztof Profic.
 * Copyright (c) 2014 Trifork A/S.
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

#import <Foundation/Foundation.h>

/**
 * Wrapper class to express operations thet their actuall execution code is somewhere else
 * than in this operation but we want to integrate them with the rest of our NSOperation/NSOperationQueue 
 * setup eg. by setting up operation dependencies.
 *
 * Operation starts executing as soon as it isReady, but it's not doing anything at all
 * It simply waits until tf_setExternalOperationCompleted:YES is called.
 */
@interface TFExternalWaitingOperation : NSOperation {
    @private
    BOOL _TFexecuting;
    BOOL _TFfinished;
}

- (void)tf_setExternalOperationCompleted:(BOOL)completed;

@end

