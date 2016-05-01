//
//  NSArray+Enumerable.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/4/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "NSArray+Enumerable.h"

@implementation NSArray (Enumerable)

- (NSArray *)mappedArrayWithBlock:(id (^)(id))block
{
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        [temp addObject:block(obj)];
    }
    
    return temp;
}

@end
