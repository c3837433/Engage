//
//  PostImageCell.m
//  EngageCells
//
//  Created by Angela Smith on 2/15/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "PostImageCell.h"

@implementation PostImageCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
// set the image
-(void)setPostImageFrom:(PFObject*)post {
    if (![[post objectForKey:@"media"] isEqual:@"text"]) {
        // GET AND SET THE MEDIA
        PFFile* storyMedia = [post objectForKey:@"mediaThumb"];
        if ([storyMedia isDataAvailable]) {
            //[cell.image loadInBackground];
            self.postImage.file = storyMedia;
            [self.postImage loadInBackground];
        } else {
            self.postImage.file = storyMedia;
            [self.postImage loadInBackground];
        }
    }

}
@end
