//
//  ProfileMediaStoryCell.m
//  Engage
//
//  Created by Angela Smith on 8/15/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "ProfileMediaStoryCell.h"

@implementation ProfileMediaStoryCell
@synthesize  storyThumb;



-(void)setProfileMediaStory:(PFObject*)story {
    // GET AND SET THE MEDIA
    PFFile* storyMedia = [story objectForKey:@"mediaThumb"];
    storyThumb.file = storyMedia;
    storyThumb.layer.cornerRadius = 8;
    [storyThumb loadInBackground];
}



@end
