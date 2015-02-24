//
//  GroupRegionsViewController.h
//  Test Engage
//
//  Created by Angela Smith on 10/29/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface GroupRegionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    
    NSMutableArray* regionsAvailable;
    IBOutlet UITableView* regionTable;
}

@property (nonatomic, strong) MBProgressHUD* progressHud;

@end
