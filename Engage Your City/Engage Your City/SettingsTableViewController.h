//
//  SettingsTableViewController.h
//  Engage
//
//  Created by Angela Smith on 8/10/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CustomAdminCreateViewController.h"
#import "MZFormSheetController.h"

@interface SettingsTableViewController : UITableViewController <NSURLConnectionDataDelegate, AdminCreateDelegate, MZFormSheetBackgroundWindowDelegate>

{
    NSUserDefaults* userDefaults;
    BOOL canLink;
    BOOL connectedToFacebook;
    IBOutlet UISwitch* toggleFBConnect;
    PFUser* user;
    IBOutlet UITableView* settingsTable;
    NSMutableData* facebookUserProfilePictureData;
}
@end
