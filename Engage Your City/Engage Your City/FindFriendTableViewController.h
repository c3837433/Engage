//
//  FindFriendTableViewController.h
//  Engage
//
//  Created by Angela Smith on 12/29/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "FriendCell.h"
#import "DZNSegmentedControl.h"
#import "MZFormSheetController.h"

@interface FindFriendTableViewController : PFQueryTableViewController <UITableViewDelegate, DZNSegmentedControlDelegate, ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, FriendCellDelegate, MZFormSheetBackgroundWindowDelegate>
{
    CFArrayRef contactsObjects;
    NSMutableArray* allEmails;
    NSMutableArray* allNames;
    NSArray *facebookFriends;
}

@property (nonatomic, strong) DZNSegmentedControl* segmentedControl;
@property (nonatomic, strong) NSArray* controlItems;
@property (nonatomic) BOOL needSearchName;
@property (nonatomic, strong) NSString* searchName;

@property (nonatomic, strong) IBOutlet UILabel* infoLineLabel;

@property (nonatomic, strong) NSString *selectedEmailAddress;
@property (nonatomic, strong) IBOutlet UITableView* friendsTable;

//- (void) sortFollowers:(NSMutableArray*)array;
/*
#define aPostText @"story"
#define aFont @"AvenirNext-Regular"
//#define _allowAppearance    YES
#define _bakgroundColor     [UIColor colorWithRed:0/255.0 green:87/255.0 blue:173/255.0 alpha:1.0]
#define _tintColor          [UIColor colorWithRed:20/255.0 green:200/255.0 blue:255/255.0 alpha:1.0]
#define _hairlineColor      [UIColor colorWithRed:0/255.0 green:36/255.0 blue:100/255.0 alpha:1.0]
*/
@end
