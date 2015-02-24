//
//  NewTextCell.h
//  EngageCells
//
//  Created by Angela Smith on 1/29/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import "UserProfileImageView.h"

@interface NewTextCell : PFTableViewCell

@property (nonatomic, strong) IBOutlet UIButton* nameButton;
@property (nonatomic, strong) IBOutlet UIButton* userImageButton;
@property (nonatomic, strong) IBOutlet UserProfileImageView *userImageView;
@property (nonatomic, strong) IBOutlet UILabel* storyTitleLabel;
@property (nonatomic, strong) IBOutlet UIButton* homeGroupButton;
@property (nonatomic, strong) IBOutlet UILabel* storyTextLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeStampLabel;
@property (nonatomic, strong) IBOutlet UIButton* likeButton;
@property (nonatomic, strong) IBOutlet UIButton* commentButton;
/*! The user represented in the cell */
@property (nonatomic, strong) PFUser* user;


// Set the content
- (void)setStoryText:(NSString *)contentString;
- (void)setTime:(NSDate *)date;
- (void)setstoryTitle:(NSString *)titleString;
-(void)setHomeGroup:(PFObject*) group;
@end
