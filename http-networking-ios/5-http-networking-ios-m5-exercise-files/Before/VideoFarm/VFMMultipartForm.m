//
//  VFMBodyData.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMMultipartForm.h"

static NSString * const VFMBodyDataBoundary = @"ThIsIsAcOnTeNtBoUnDaRy";

@interface VFMMultipartForm ()

@property (nonatomic, strong) NSMutableData *data;

@end

@implementation VFMMultipartForm

- (id)init
{
    if ((self = [super init])) {
        self.data = [NSMutableData data];
    }

    return self;
}

#pragma mark - Instance methods

- (void)addFormValue:(NSString *)value forName:(NSString *)name
{
    [self appendBoundary];
    [self appendNewline];

    [self appendFieldNamed:name];
    [self appendNewline];
    [self appendNewline];
    
    [self.data appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
    [self appendNewline];
}

- (void)addPNGImage:(UIImage *)image forName:(NSString *)name
{
    [self appendBoundary];
    [self appendNewline];

    [self appendFieldNamed:name];
    [self.data appendData:[@"; filename=\"image.png\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [self appendNewline];
    [self appendContentType:@"image/png"];
    
    [self appendNewline];
    [self appendNewline];

    [self.data appendData:UIImagePNGRepresentation(image)];
    [self appendNewline];
}

- (void)addJPEGImage:(UIImage *)image forName:(NSString *)name
{
    [self appendBoundary];
    [self appendNewline];
    
    [self appendFieldNamed:name];
    [self.data appendData:[@"; filename=\"image.jpeg\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [self appendNewline];
    [self appendContentType:@"image/jpeg"];
    
    [self appendNewline];
    [self appendNewline];
    
    [self.data appendData:UIImageJPEGRepresentation(image, 1.0)];
    [self appendNewline];
}

- (void)addFileAtURL:(NSURL *)URL
         contentType:(NSString *)contentType
            fileName:(NSString *)fileName
             forName:(NSString *)name
{
    [self appendBoundary];
    [self appendNewline];
    
    [self appendFieldNamed:name];
    [self appendContentType:contentType];
    
    [self appendNewline];
    [self appendNewline];
    
    [self.data appendData:[NSData dataWithContentsOfURL:URL]];
    [self appendNewline];
}

- (NSData *)finalizedData
{
    NSMutableData *dataCopy = [NSMutableData dataWithData:self.data];
    
    NSString *finalBoundary = [NSString stringWithFormat:@"--%@--\r\n", VFMBodyDataBoundary];
    [dataCopy appendData:[finalBoundary dataUsingEncoding:NSUTF8StringEncoding]];

    return [NSData dataWithData:dataCopy];
}

- (NSString *)contentType
{
    return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", VFMBodyDataBoundary];
}

#pragma mark - Private Helpers

- (void)appendFieldNamed:(NSString *)name
{
    NSString *string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", name];
    [self.data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendContentType:(NSString *)contentType
{
    NSString *string = [NSString stringWithFormat:@"Content-Type: %@", contentType];
    [self.data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendBoundary
{
    [self.data appendData:[@"--" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.data appendData:[VFMBodyDataBoundary dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendNewline
{
    [self.data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
