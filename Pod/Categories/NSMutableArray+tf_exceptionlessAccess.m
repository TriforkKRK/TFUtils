//
//  NSMutableArray+tf_exceptionlessAccess.m
//  Pods
//
//  Created by Wojciech Nagrodzki on 24/06/15.
//
//

#import "NSMutableArray+tf_exceptionlessAccess.h"

@implementation NSMutableArray (tf_exceptionlessAccess)

- (void)addObjectIfNotNil:(id)anObject
{
    if (anObject == nil) return;
    [self addObject:anObject];
}

@end
