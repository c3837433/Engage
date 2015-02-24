//
//  FriendCell.h
//  Engage
//
//  Created by Angela Smith on 12/29/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
@protocol FriendCellDelegate;

@interface FriendCell : PFTableViewCell

{
    id _delegate;
}

@property (nonatomic, strong) id<FriendCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel* friendNameLabel;
@property (nonatomic, strong) IBOutlet UILabel* friendGroupLabel;
@property (nonatomic, strong) IBOutlet UILabel* friendStoriesLabel;
@property (nonatomic, strong) IBOutlet PFImageView* friendPic;
@property (nonatomic, strong) IBOutlet UIButton* followButton;
@property (nonatomic, strong) PFUser *user;

- (void)setUser:(PFUser *)user;
- (IBAction)didTapFollowButtonAction:(id)sender;

@end

/*!
 The protocol defines methods a delegate of a FriendCell should implement.
 */
@protocol FriendCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (IBAction)cellView:(FriendCell *)cellView didTapFollowButton:(UIButton*)button aUser:(PFUser *)aUser;

@end
