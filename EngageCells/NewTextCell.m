//
//  NewTextCell.m
//  EngageCells
//
//  Created by Angela Smith on 1/29/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "NewTextCell.h"
#import "Utility.h"

@implementation NewTextCell

@synthesize nameButton, userImageButton, userImageView, storyTextLabel, storyTitleLabel, timeStampLabel, user;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Set name button properties and avatar image
    /*  if ([Utility userHasProfilePictures:self.user]) {
     [self.userImageView setProfileImageFile:[self.user objectForKey:@"profilePictureSmall"]];
     } else {
     [self.userImageView setProfileImageView:[Utility defaultProfilePicture]];
     }
     */
    [self.nameButton setTitle:[self.user objectForKey:@"UsersFullName"] forState:UIControlStateNormal];
    [self.nameButton setTitle:[self.user objectForKey:@"UsersFullName"] forState:UIControlStateHighlighted];
    [self.nameButton sizeToFit];
    
    // If user is set after the contentText, we reset the content to include padding
    /*  if (self.storyTextLabel.text) {
     [self setStoryText:self.storyTextLabel.text];
     }*/
    // [self setNeedsDisplay];
}

-(void)setHomeGroup:(PFObject*) group {
    
    NSString* homegroup = [group objectForKey:@"groupHeader"];
    NSLog(@"User homegroup = %@", homegroup);
    [self.homeGroupButton setTitle:homegroup forState:UIControlStateNormal];
    [self.homeGroupButton setTitle:homegroup forState:UIControlStateHighlighted];
    [self.homeGroupButton sizeToFit];
}

-(void)setstoryTitle:(NSString *)titleString {
    [self.storyTitleLabel setText:titleString];
    
}

- (void)setStoryText:(NSString *)contentString {
    // If we have a user we pad the content with spaces to make room for the name
    [self.storyTextLabel setText:contentString];
}

- (void)setTime:(NSDate *)date {
    // Set the label with a human readable tim
    // Set the time interval
    Utility* utility = [[Utility alloc] init];
    NSString* timeStampString = [utility stringForTimeIntervalSinceCreated:date];
    [self.timeStampLabel setText:timeStampString];
    // [self setNeedsDisplay];
}
@end

