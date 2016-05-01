//
//  VFMAPIRequest.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMAPIRequest.h"

@interface VFMAPIRequest ()

@property (nonatomic, assign, readwrite) NSUInteger expectedStatusCode;
@property (nonatomic, copy, readwrite) VFMAPIRequestSuccess success;
@property (nonatomic, copy, readwrite) VFMAPIRequestFailure failure;
@property (nonatomic, strong) NSMutableData *mutableData;

@end

@implementation VFMAPIRequest

#pragma mark - Instance methods

- (instancetype)initWithExpectedStatusCode:(NSUInteger)expectedStatusCode
                                   success:(VFMAPIRequestSuccess)success
                                   failure:(VFMAPIRequestFailure)failure
{
    if ((self = [super init])) {
        self.expectedStatusCode = expectedStatusCode;
        self.success = success;
        self.failure = failure;
        
        self.mutableData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)appendData:(NSData *)data
{
    [self.mutableData appendData:data];
}

- (NSData *)responseData
{
    return [NSData dataWithData:self.mutableData];
}

@end
