//
//  UserDetailsViewController.h
//  Engage
//
//  Created by Angela Smith on 2/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "MZFormSheetController.h"
#import "CustomAddPostViewController.h"
#import "CustomEditProfileViewController.h"

@interface UserDetailsViewController : PFQueryTableViewController  <CustomAddPostDelegate, CustomEditProfileDelegate, MZFormSheetBackgroundWindowDelegate>

@property (nonatomic, strong) PFUser* thisUser;
@property (nonatomic) BOOL fromPanel;

// Set up profile data
@property (nonatomic, strong) IBOutlet PFImageView* profilePicView;
@property (nonatomic, strong) IBOutlet PFImageView* fullbgPicView;
@property (nonatomic, strong) IBOutlet UIButton* homeGroupButton;
@property (nonatomic, strong) IBOutlet UIButton* followEditButton;
@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel* userFollowLabel;
@property (nonatomic, strong) IBOutlet UILabel* userPostCountLabel;
@property (nonatomic, strong) IBOutlet UILabel* userAboutMeLabel;
@property (nonatomic, strong) IBOutlet UILabel* userLocationLabel;
@property (nonatomic, strong) IBOutlet UIView* detailsView;
@property (nonatomic, strong) PFObject* selectedStory;
@property (nonatomic, strong) NSString* userId;


@end
