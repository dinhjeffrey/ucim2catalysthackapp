//
//  NSHTTPURLResponse+ChatcaveExtensions.m
//  ChatCave
//
//  Created by Alex Vollmer on 5/15/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "NSHTTPURLResponse+ChatcaveExtensions.h"

@implementation NSHTTPURLResponse (ChatcaveExtensions)

- (NSString *)errorMessageWithData:(NSData *)data
{
    NSString *message = [NSString stringWithFormat:@"Unexpected response code: %li", (long)self.statusCode];
    
    if (data) {
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            NSString *errorMessage = [(NSDictionary *)json valueForKey:@"error"];
            if (errorMessage) {
                message = errorMessage;
            }
        }
    }
    
    return message;
}

@end
