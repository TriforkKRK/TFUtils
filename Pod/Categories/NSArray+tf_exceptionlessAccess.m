//
//  NSArray+tf_exceptionlessAccess.m
//  TFUtils
//
//  Created by Wojciech Nagrodzki on 24/06/15.
//  Copyright (c) 2015 Krzysztof Profic. All rights reserved.
//

#import "NSArray+tf_exceptionlessAccess.h"

@implementation NSArray (tf_exceptionlessAccess)

- (id)objectAtIndexIfPresentOrNil:(NSUInteger)index
{
    if (index < self.count) return [self objectAtIndex:index];
    return nil;
}

@end
