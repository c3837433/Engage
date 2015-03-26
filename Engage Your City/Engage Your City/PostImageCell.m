//
//  PostImageCell.m
//  EngageCells
//
//  Created by Angela Smith on 2/15/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "PostImageCell.h"

@implementation PostImageCell

// set the image
-(void)setPostImageFrom:(PFObject*)post {
    if (![[post objectForKey:@"media"] isEqual:@"text"]) {
        // GET AND SET THE MEDIA
        PFFile* storyMedia = [post objectForKey:@"mediaThumb"];
        if ([storyMedia isDataAvailable]) {
           // NSLog(@"This image is not available");
            self.postImage.file = storyMedia;
            [self.postImage loadInBackground];
        } else {
            //NSLog(@"This image has been stored in memory");
            self.postImage.file = storyMedia;
            [self.postImage loadInBackground];
        }
        // If this is not a video, hide the play button
        if (![[post objectForKey:@"media"] isEqual:@"video"]) {
            // hide the play button
            self.playButton.hidden = YES;
        }
    }

}
@end
