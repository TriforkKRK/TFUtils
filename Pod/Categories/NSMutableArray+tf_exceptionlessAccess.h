//
//  NSMutableArray+tf_exceptionlessAccess.h
//  Pods
//
//  Created by Wojciech Nagrodzki on 24/06/15.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (tf_exceptionlessAccess)

- (void)addObjectIfNotNil:(id)anObject;

@end
