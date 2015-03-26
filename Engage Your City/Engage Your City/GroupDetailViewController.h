//
//  GroupDetailViewController.h
//  Engage Your City
//
//  Created by Angela Smith on 3/18/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface GroupDetailViewController : UIViewController <UITableViewDataSource, UITextFieldDelegate>


@property (nonatomic, strong) PFObject* group;
@property (nonatomic, strong) IBOutlet PFImageView* fullbgPicView;
@property (nonatomic, strong) IBOutlet UIButton* followButton;
@property (nonatomic, strong) IBOutlet UIButton* joinButton;
@property (nonatomic, strong) IBOutlet UILabel* groupLeaderNameLabel;
@property (nonatomic, strong) IBOutlet UILabel* groupFollowLabel;
@property (nonatomic, strong) IBOutlet UILabel* groupAboutUsLabel;
@property (nonatomic, strong) IBOutlet UIView* detailsView;

@property (nonatomic, strong) IBOutlet UITableView* detailsTable;

@end
