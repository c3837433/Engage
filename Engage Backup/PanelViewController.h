//
//  PanelViewController.h
//  Test Engage
//
//  Created by Angela Smith on 8/17/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PanelViewController : UIViewController <PFLogInViewControllerDelegate>

//@property (nonatomic, strong) XDKAirMenuController *airMenuController;
@property IBOutlet PFImageView* userProfileImage;
@property IBOutlet UILabel* userProfileNameLabel;
@property  NSString* userName;
@property  NSString* homeGroupName;
@property PFObject* userObject;

@end
