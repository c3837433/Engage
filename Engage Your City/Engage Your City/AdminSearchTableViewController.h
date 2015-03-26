//
//  AdminSearchTableViewController.h
//  Engage Your City
//
//  Created by Angela Smith on 3/25/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface AdminSearchTableViewController : PFQueryTableViewController

@property (nonatomic, strong) NSString* nameSearch;
@property (nonatomic, strong) PFUser* selectedUser;

@end
