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

@interface FindFriendTableViewController : PFQueryTableViewController <UITableViewDelegate, ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, FriendCellDelegate>
{
    CFArrayRef contactsObjects;
    NSMutableArray* allEmails;
    NSMutableArray* allNames;
}

@property (nonatomic, strong) NSMutableDictionary* activityQueries;
@property (nonatomic, strong) NSArray* topFollowedUsers;
@property (nonatomic, strong) IBOutlet UIButton* topFollowsButton;
@property (nonatomic, strong) IBOutlet UIButton* facebookFriendsButton;
@property (nonatomic, strong) IBOutlet UIButton* contactsButton;
@property (nonatomic, strong) IBOutlet UILabel* infoLineLabel;

typedef enum {
    FindFriendsFollowingNone = 0,    // User isn't following anybody in Friends list
    FindFriendsFollowingAll,         // User is following all Friends
    FindFriendsFollowingSome         // User is following some of their Friends
} FindFriendsFollowStatus;

typedef enum {
    FindTopFollowed = 0,    // Display standard
    FindFacebookFriends,         // Display Facebook Friends
    FindContactFriends         // Display matching contacts
} FindFriendsSearch;

@property (nonatomic, assign) FindFriendsFollowStatus followStatus;
@property (nonatomic, assign) FindFriendsSearch searchStatus;
@property (nonatomic, strong) NSString *selectedEmailAddress;
@property (nonatomic, strong) NSMutableDictionary *outstandingFollowQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingCountQueries;
@property (nonatomic, strong) IBOutlet UITableView* friendsTable;

- (void) sortFollowers:(NSMutableArray*)array;

@end
