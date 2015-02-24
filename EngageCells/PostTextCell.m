//
//  PostTextCell.m
//  EngageCells
//
//  Created by Angela Smith on 2/15/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "PostTextCell.h"
#import "Utility.h"

@implementation PostTextCell
@synthesize thisPost, thisPostAuthor, postAuthorNameButton, postAuthorGroupButton, postAuthorImage, postStoryLabel, postTimeStampLabel, postTitleLabel, postAuthorPicButton, backgroundView;

// Set up the cell
-(void)setPost:(PFObject*)post {
   
    // set background
    backgroundView.layer.cornerRadius = 8.0f;
    // Border
    [backgroundView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [backgroundView.layer setBorderWidth:0.3f];
    // Shadow
    [backgroundView.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [backgroundView.layer setShadowOpacity:0.8];
    [backgroundView.layer setShadowRadius:0.8];
    [backgroundView.layer setShadowOffset:CGSizeMake(0.8, 0.8)];
    
    // GET THE STORY
    thisPost = post;
    
    // SET AUTHOR PICTURE
    thisPostAuthor = [thisPost objectForKey:aPostAuthor];
    // Set name button properties and avatar image
    if ([thisPostAuthor objectForKey:aPostAuthorImage]) {
        // NSLog(@"The author HAS profile image");
        PFFile* imageFile = [thisPostAuthor objectForKey:aPostAuthorImage];
        if ([imageFile isDataAvailable]) {
            //[cell.image loadInBackground];
            postAuthorImage.file = imageFile;
            [postAuthorImage loadInBackground];
        } else {
            postAuthorImage.file = imageFile;
            [postAuthorImage loadInBackground];
        }
    } else {
        //  NSLog(@"The author has NO profile image");
        postAuthorImage.image = [UIImage imageNamed:@"placeholder"];
    }
    
    
    // SET AUTHOR NAME
    [postAuthorNameButton setTitle:[thisPostAuthor objectForKey:aPostAuthorName] forState:UIControlStateNormal];
    //NSLog(@"Users name = %@", [storyAuthor objectForKey:@"UsersFullName"] );
    [postAuthorNameButton setTitle:[thisPostAuthor objectForKey:aPostAuthorName] forState:UIControlStateHighlighted];
    //[postAuthorButton sizeToFit];
    
    // SET LOCAL GROUP
    if ([thisPost objectForKey:aPostAuthorGroup]) {
        PFObject* group = [thisPost  objectForKey:aPostAuthorGroup];
        [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [postAuthorGroupButton setTitle:[group objectForKey:aPostAuthorGroupTitle] forState:UIControlStateNormal];
            [postAuthorGroupButton setTitle:[group objectForKey:aPostAuthorGroupTitle] forState:UIControlStateHighlighted];
            //homeGroupLabel.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
            // [self.sLocalButton sizeToFit];
        }];
    }
    
    
    // SET TIME STAMP
    NSDate* timeCreated = thisPost .createdAt;
    // Set the time interval
    Utility* utility = [[Utility alloc] init];
    NSString* timeStampString = [utility stringForTimeIntervalSinceCreated:timeCreated];
    postTimeStampLabel.text = timeStampString;
    
    // SET TITLE AND TEXT
    postTitleLabel.text = [thisPost objectForKey:aPostTitle];
    postStoryLabel.text = [thisPost  objectForKey:aPostText];
    
    /*
    // Set image if necessary
    if (![[thisPost objectForKey:@"media"] isEqual:@"text"]) {
        // GET AND SET THE MEDIA
        PFFile* storyMedia = [thisPost objectForKey:@"mediaThumb"];
        if ([storyMedia isDataAvailable]) {
            //[cell.image loadInBackground];
            postImage.file = storyMedia;
            [postImage loadInBackground];
        } else {
            postImage.file = storyMedia;
            [postImage loadInBackground];
        }
    }*/
    
}
@end
