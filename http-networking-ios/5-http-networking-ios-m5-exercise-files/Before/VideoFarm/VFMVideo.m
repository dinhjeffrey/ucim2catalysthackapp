//
//  VFMVideo.m
//  
//
//  Created by Alex Vollmer on 5/22/14.
//
//

#import "VFMVideo.h"

static NSString * const VFMVideoTitleKey = @"title";
static NSString * const VFMVideoDescriptionKey = @"videoDescription";

@interface VFMVideo ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *videoDescription;

@end

@implementation VFMVideo

- (instancetype)initWithTitle:(NSString *)title videoDescription:(NSString *)videoDescription
{
    if ((self = [super init])) {
        self.title = title;
        self.videoDescription = videoDescription;
    }
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithTitle:[aDecoder decodeObjectForKey:VFMVideoTitleKey]
              videoDescription:[aDecoder decodeObjectForKey:VFMVideoDescriptionKey]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:VFMVideoTitleKey];
    [aCoder encodeObject:self.videoDescription forKey:VFMVideoDescriptionKey];
}

@end
