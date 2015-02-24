//
//  EImageView.m
//  EngageCells
//
//  Created by Angela Smith on 1/30/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "EImageView.h"

@interface EImageView ()

@property (nonatomic, strong) PFFile *currentFile;
@property (nonatomic, strong) NSString *url;

@end

@implementation EImageView

@synthesize currentFile,url;
@synthesize placeholderImage;

#pragma mark - EImageView

- (void) setFile:(PFFile *)file {
    
    NSString *requestURL = file.url; // Save copy of url locally (will not change in block)
    [self setUrl:file.url]; // Save copy of url on the instance
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            if ([requestURL isEqualToString:self.url]) {
                [self setImage:image];
                [self setNeedsDisplay];
            }
        } else {
            NSLog(@"Error on fetching file");
        }
    }];
}


@end
