//
//  ImageView.m
//  EngageCells
//
//  Created by Angela Smith on 1/29/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "ImageView.h"

@implementation ImageView
@synthesize usersFile, placeHolderImage, imageUrl;

- (void) setImageFile:(PFFile *)imageFile {
    
    NSString* imageUrlString = imageFile.url;
    [self setImageUrl:imageFile.url];
    
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage* image = [UIImage imageWithData:data];
            if ([imageUrlString isEqualToString:self.imageUrl]) {
                [self setImage:image];
                [self setNeedsDisplay];
            }
        } else {
            NSLog(@"Error on fetching file");
        }
    }];
}

@end
