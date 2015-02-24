//
//  UserDetailsViewController.h
//  Engage
//
//  Created by Angela Smith on 2/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "DZNSegmentedControl.h"

@interface UserDetailsViewController : PFQueryTableViewController  <DZNSegmentedControlDelegate>


@property (nonatomic, strong) DZNSegmentedControl* segmentedControl;
@property (nonatomic, strong) NSArray* controlItems;
@property (nonatomic, strong) PFUser* thisUser;
@property (nonatomic) BOOL* fromPanel;

// Set up profile data
@property (nonatomic, strong) IBOutlet PFImageView* profilePicView;
@property (nonatomic, strong) IBOutlet UIButton* homeGroupButton;
@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;


@end
