//
//  NSArray+tf_exceptionlessAccess.h
//  TFUtils
//
//  Created by Wojciech Nagrodzki on 24/06/15.
//  Copyright (c) 2015 Krzysztof Profic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (tf_exceptionlessAccess)

- (id)objectAtIndexIfPresentOrNil:(NSUInteger)index;

@end
