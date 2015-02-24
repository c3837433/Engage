//
//  GroupsListViewController.h
//  Test Engage
//
//  Created by Angela Smith on 10/29/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface GroupsListViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate>
{

    NSMutableArray* homeGroupsArray;
    IBOutlet UITableView* homegroupsTable;
    IBOutlet UILabel* selectedHomeGroup;
    IBOutlet UILabel* chooseGroupLabel;
    NSUserDefaults* defaults;
    NSString* facebookFullName;
    NSString* facebookEmail;
    NSString* selectedGroup;
    NSString* userSelectedGroup;
    //IBOutlet UIBarButtonItem* nextButton;
    NSMutableData* fbData;
    NSIndexPath* selectedIndexPath;
}

@property (nonatomic, strong) NSString* currentSelection;
@property (nonatomic, strong) MBProgressHUD* progressHud;
@property (nonatomic, strong) NSString* selectedRegion;
@end
