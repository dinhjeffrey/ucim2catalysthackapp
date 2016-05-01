//
//  VFMImageStore.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/21/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMImageStore.h"

@interface VFMImageStore ()

@property (nonatomic, strong) NSURLCache *cache;

@end

@implementation VFMImageStore

+ (instancetype)sharedInstance
{
    static VFMImageStore *_vfm_SharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _vfm_SharedInstance = [[VFMImageStore alloc] init];
    });
    
    return _vfm_SharedInstance;
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.cache = [[NSURLCache alloc] initWithMemoryCapacity:512 * 1024
                                                   diskCapacity:2 * 1024 * 1024
                                                       diskPath:NSStringFromClass([self class])];
    }
    
    return self;
}

- (UIImage *)imageForURLRequest:(NSURLRequest *)request
                    placeholder:(UIImage *)placeholderImage
                    whenFetched:(void (^)(NSURLRequest *, UIImage *))callback
{
    NSCachedURLResponse *cachedResponse = [self.cache cachedResponseForRequest:request];
    if (cachedResponse) {
        return [UIImage imageWithData:cachedResponse.data];
    }
    else {
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if (data != nil && error == nil) {
                                                            NSCachedURLResponse *cacheResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                                                            [self.cache storeCachedResponse:cacheResponse forRequest:request];
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                UIImage *image = [UIImage imageWithData:data];
                                                                callback(request, image);
                                                            });
                                                        }
                                                        else if (error) {
                                                            NSLog(@"ERROR fetching %@: %@", request.URL, error);
                                                        }
                                                    }];
        [dataTask resume];
        
        return placeholderImage;
    }
}

@end
