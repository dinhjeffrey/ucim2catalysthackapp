//
//  VFMVideo.h
//  
//
//  Created by Alex Vollmer on 5/22/14.
//
//

#import <Foundation/Foundation.h>

/**
 * A simple model of a video, regardless of where it may exist
 */
@interface VFMVideo : NSObject <NSCoding>

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *videoDescription;

- (instancetype)initWithTitle:(NSString *)title
             videoDescription:(NSString *)videoDescription;

@end
