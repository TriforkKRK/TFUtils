/*
 * Created by Krzysztof Profic on 14/04/14.
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


#import "TFExpirableObject.h"

@interface TFExpirableObject()
@property (strong, nonatomic) NSDate * creationDate;

@end

@implementation TFExpirableObject

#pragma mark - Interface Methods

- (NSTimeInterval)liveTime
{
    [NSException raise:NSInternalInconsistencyException format:@"This is template method, you have to provide your own implementation in subclasses."];
    return 0;
}

#pragma mark - Overriden

- (instancetype)init
{
    self = [super init];
    if (self) {
        _creationDate = [NSDate date];
    }
    return self;
}

#pragma mark - NSDiscardableContent

- (BOOL)beginContentAccess
{
    return YES;
}
- (void)endContentAccess
{
    // do nothing
}
- (void)discardContentIfPossible
{
    // do nothing, content is automatically discarded when livetime expires.
}

- (BOOL)isContentDiscarded
{
    return [[self expirationDate] timeIntervalSinceNow] < 0;
}
            
#pragma mark - Private Methods

- (NSDate *)expirationDate
{
    NSTimeInterval lt = [self liveTime];
    NSParameterAssert(lt > 0);
    return [self.creationDate dateByAddingTimeInterval:lt];
}

@end