//
//  FriendCell.m
//  Engage
//
//  Created by Angela Smith on 12/29/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "FriendCell.h"

@implementation FriendCell

@synthesize followButton, friendGroupLabel, friendNameLabel, friendPic, friendStoriesLabel, delegate, user;

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
    // Configure the cell
    // User Image
    PFFile *profilePictureSmall = [user objectForKey:@"profilePictureSmall"];
    friendPic.file = profilePictureSmall;
    [friendPic loadInBackground];
    // Set name
    [friendNameLabel setText:[user objectForKey:@"UserProfileName"]];
    // Set group
    PFObject* group = [user objectForKey:@"group"];
    friendGroupLabel.text = [group objectForKey:@"groupHeader"];
    
    [followButton addTarget:self action:@selector(didTapFollowButtonAction:)
           forControlEvents:UIControlEventTouchUpInside];
}

/* Inform delegate that the follow button was tapped */

- (IBAction)didTapFollowButtonAction:(UIButton*)button {
    if (delegate && [delegate respondsToSelector:@selector(cellView:didTapFollowButton:aUser:)]) {
        [delegate cellView:self didTapFollowButton:button aUser:self.user];
    }
}

@end
