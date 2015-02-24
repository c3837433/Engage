//
//  FindFriendTableViewController.m
//  Engage
//
//  Created by Angela Smith on 12/29/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "FindFriendTableViewController.h"
#import "Utility.h"
#import "Cache.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FindFriendTableViewController () 

@end

@implementation FindFriendTableViewController

@synthesize followStatus, searchStatus, selectedEmailAddress, outstandingCountQueries, outstandingFollowQueries, friendsTable, topFollowedUsers, topFollowsButton, facebookFriendsButton, contactsButton, infoLineLabel;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"_User"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.outstandingFollowQueries = [NSMutableDictionary dictionary];
        self.outstandingCountQueries = [NSMutableDictionary dictionary];
        
        self.parseClassName = @"_User";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of objects to show per page
        self.objectsPerPage = 7;
        // Used to determine Follow/Unfollow All button status
        self.followStatus = FindFriendsFollowingSome;
        self.searchStatus = FindTopFollowed;
    }
    return self;
}

- (IBAction)searchForNewfriends:(UIButton*)button {
    // see what button was selected
    if (button.tag == 0) {
        self.searchStatus = FindFacebookFriends;
        // Highlight the facebook button
        [facebookFriendsButton setSelected:true];
        [topFollowsButton setSelected:false];
        [contactsButton setSelected:false];
        [infoLineLabel setText:@"Your Facebook friends using Engage"];
    } else if (button.tag == 1) {
        self.searchStatus = FindContactFriends;
        // Highlight the facebook button
        [facebookFriendsButton setSelected:false];
        [topFollowsButton setSelected:false];
        [contactsButton setSelected:true];
        [infoLineLabel setText:@"People in your contacts"];
    } else if (button.tag == 2) {
        self.searchStatus = FindTopFollowed;
        // Highlight the facebook button
        [facebookFriendsButton setSelected:false];
        [topFollowsButton setSelected:true];
        [contactsButton setSelected:false];
        [infoLineLabel setText:@"Select from our most followed users"];
    }
    // reload the table
    [self loadObjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)pullStories
{
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"activityType" equalTo:@"follow"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    // Make sure we get the user info with it
    [query includeKey:@"toUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        NSMutableArray* follows = [[NSMutableArray alloc] init];
        for (PFObject* activity in  activities) {
            PFUser* user = [activity objectForKey:@"toUser"];
            NSString* userId = user.objectId;
            [follows addObject: userId];
        }
        [self sortFollowers:follows];
    }];
}
-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [self pullStories];
}

- (void) sortFollowers:(NSMutableArray*)array {
    //NSLog(@"Followed Users: %@", array.description);
    NSCountedSet *set = [[NSCountedSet alloc] initWithArray:array];
    NSArray* sortedValues = [set.allObjects sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSUInteger n = [set countForObject:obj1];
        NSUInteger m = [set countForObject:obj2];
        return (n <= m)? (n < m)? NSOrderedAscending : NSOrderedSame : NSOrderedDescending;
    }];
    //NSLog(@"Sorted Top Followed Users: %@", sortedValues.description);
    
    // Finally get only the top ten
    topFollowedUsers = [sortedValues subarrayWithRange:NSMakeRange(0, 7)];
    NSLog(@"Top Followed Users: %@", topFollowedUsers.description);
    [self loadObjects];
}

#pragma mark - PFQueryTableViewController
- (PFQuery *)queryForTable {
    
    if (self.searchStatus == FindTopFollowed) {
        NSLog(@"Loading Top %lu Users", (unsigned long)topFollowedUsers.count);
        PFQuery* topFollowedUsersQuery = [PFUser query];
        [topFollowedUsersQuery whereKey:@"objectId" containedIn:topFollowedUsers];
        topFollowedUsersQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        [topFollowedUsersQuery includeKey:@"group"];
        [topFollowedUsersQuery orderByAscending:@"UsersFullName"];
        if (self.objects.count == 0) {
            topFollowedUsersQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
            NSLog(@"No users returned ");
        } else {
            NSLog(@"Loading %lu users", (unsigned long)self.objects.count);
        }
        return topFollowedUsersQuery;
    } else if (self.searchStatus == FindFacebookFriends) {
        // Make sure the user is logged in through facebook!
        
        // Use cached facebook friend ids
        NSArray *facebookFriends = [[Cache sharedCache] facebookFriends];
        NSLog(@"facebook friends in cache: %@", facebookFriends.description);
        // Query for all friends you have on facebook and who are using the app
        
        PFQuery *friendQuery = [PFUser query];
        [friendQuery whereKey:@"facebookId" containedIn:facebookFriends];
        // findObjects will return a list of PFUsers that are friends
        friendQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        [friendQuery includeKey:@"group"];
        [friendQuery orderByAscending:@"UsersFullName"];
        if (self.objects.count == 0) {
            friendQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
            NSLog(@"No users returned ");
        } else {
            NSLog(@"Loading %lu users", (unsigned long)self.objects.count);
        }
        return friendQuery;
        
    } else {
        // Start the email and name queries
        PFQuery* emailQuery = [PFUser query];
        PFQuery* nameQuery = [PFUser query];
        
        CFErrorRef error = nil;
        // Request authorization to Address Book
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    contactsObjects = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
                    // and an array of all their email addresses
                    allEmails = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(contactsObjects)];
                    allNames = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(contactsObjects)];
                    for (CFIndex i = 0; i < CFArrayGetCount(contactsObjects); i++) {
                        ABRecordRef person = CFArrayGetValueAtIndex(contactsObjects, i);
                        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
                        for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                            NSString* contactFirst  = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                            NSString* contactLast  =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
                            
                            if (!contactFirst) {
                                contactFirst = @"";
                            }
                            if (!contactLast) {
                                contactLast = @"";
                            }
                            NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                            NSString* fullName = [NSString stringWithFormat:@"%@ %@", contactFirst, contactLast];
                            NSLog(@"EMAIL: %@",email);
                            if (![email isEqualToString:@""]) {
                                [allEmails addObject:email];
                            }
                            
                            if (![fullName isEqualToString:@""]) {
                                [allNames addObject:fullName];
                            }
                            
                        }
                    }
                    
                    [emailQuery whereKey:@"email" containedIn:allEmails];
                    [nameQuery whereKey:@"UsersFullName" containedIn:allNames];
                    // Start the contact query looking for users with either a matching email or name from the users address book
                } else {
                    // User denied access. Inform user we are unable to find friends without approval
                    NSLog(@"User has denied permission");
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access, add all the user's contacts to array.
            NSLog(@"User has previously granted permission");
            // get an array of all contacts
            contactsObjects = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
            // and an array of all their email addresses
            allEmails = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(contactsObjects)];
            allNames = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(contactsObjects)];
            for (CFIndex i = 0; i < CFArrayGetCount(contactsObjects); i++) {
                ABRecordRef person = CFArrayGetValueAtIndex(contactsObjects, i);
                ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
                for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                    NSString* contactFirst  = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                    NSString* contactLast  =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
                    
                    if (!contactFirst) {
                        contactFirst = @"";
                    }
                    if (!contactLast) {
                        contactLast = @"";
                    }
                    NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                    NSString* fullName = [NSString stringWithFormat:@"%@ %@", contactFirst, contactLast];
                    NSLog(@"EMAIL: %@",email);
                    if (![email isEqualToString:@""]) {
                        [allEmails addObject:email];
                    }
                    
                    if (![fullName isEqualToString:@""]) {
                        [allNames addObject:fullName];
                    }
                    
                }
            }
            
            [emailQuery whereKey:@"email" containedIn:allEmails];
            [nameQuery whereKey:@"UsersFullName" containedIn:allNames];
            // Start the contact query looking for users with either a matching email or name from the users address book
            
        }
        else {
            // The user has previously denied access
            NSLog(@"User has previously denied permission");
            // Send an alert telling user that they must allow access to proceed to the "invites" page.
        }
        NSLog(@"Running query");
        PFQuery* contactQuery = [PFQuery orQueryWithSubqueries:@[emailQuery,nameQuery]];
        contactQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        [contactQuery includeKey:@"group"];
        [contactQuery orderByAscending:@"UsersFullName"];
        [contactQuery whereKey: @"email" notEqualTo: [[PFUser currentUser] objectForKey: @"email"]];
        return contactQuery;
    }
    
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    //NSLog(@"Finding first follower");
    static NSString *FriendCellIdentifier = @"followFriendCell";
    
    FriendCell* cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell != nil) {
        cell.delegate = self;
        [cell setUser:(PFUser*)object];
        cell.followButton.tag = indexPath.row;
        
        // Set the default stories
        [cell.friendStoriesLabel setText:@"Shared 0 stories"];
        // See if we have attributes for this user
        NSDictionary *attributes = [[Cache sharedCache] attributesForUser:(PFUser *)object];
        // If we do
        if (attributes) {
            // set them now
            NSNumber *number = [[Cache sharedCache] photoCountForUser:(PFUser *)object];
            //NSLog(@"This person at %ld has %@ stories", (long)indexPath.row, number);
            [cell.friendStoriesLabel setText:[NSString stringWithFormat:@"Shared %@ %@", number, [number intValue] == 1 ? @"story": @"stories"]];
        } else {
            // Get them
            @synchronized(self) {
                NSNumber *outstandingCountQueryStatus = [self.outstandingCountQueries objectForKey:indexPath];
                if (!outstandingCountQueryStatus) {
                    [self.outstandingCountQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                    // Look up the number of testimpnies this person has shared
                    PFQuery* storyNumQuery = [PFQuery queryWithClassName:@"Testimonies"];
                    [storyNumQuery whereKey:@"author" equalTo:object];
                    [storyNumQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                    [storyNumQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                        @synchronized(self) {
                            [[Cache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:(PFUser *)object];
                            [self.outstandingCountQueries removeObjectForKey:indexPath];
                        }
                        FriendCell* actualCell = (FriendCell*)[tableView cellForRowAtIndexPath:indexPath];
                        // set the label
                        [actualCell.friendStoriesLabel setText:[NSString stringWithFormat:@"Shared %d %@", number, number == 1 ? @"story" : @"stories"]];
                    }];
                };
            }
        }
        cell.followButton.selected = NO;
        cell.followButton.tag = indexPath.row;
        cell.tag = indexPath.row;
        //
        if (self.followStatus == FindFriendsFollowingSome) {
            // See if we have user attributes for followers
            if (attributes) {
                // set them accordingly
                [cell.followButton setSelected:[[Cache sharedCache] followStatusForUser:(PFUser *)object]];
            } else {
                // Get the people this user follows
                @synchronized(self) {
                    NSNumber *outstandingQuery = [self.outstandingFollowQueries objectForKey:indexPath];
                    if (!outstandingQuery) {
                        [self.outstandingFollowQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                        PFQuery *isFollowingQuery = [PFQuery queryWithClassName:@"Activity"];
                        [isFollowingQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
                        [isFollowingQuery whereKey:@"activityType" equalTo:@"follow"];
                        [isFollowingQuery whereKey:@"toUser" equalTo:object];
                        [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                        
                        [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                            @synchronized(self) {
                                [self.outstandingFollowQueries removeObjectForKey:indexPath];
                                [[Cache sharedCache] setFollowStatus:(!error && number > 0) user:(PFUser *)object];
                            }
                            if (cell.tag == indexPath.row) {
                                [cell.followButton setSelected:(!error && number > 0)];
                            }
                        }];
                    }
                }
            }
        }
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"loadMoreCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return cell;
}


#pragma mark - FriendCellDelegate
- (void)cellView:(FriendCell *)cellView didTapFollowButton:(UIButton*)button aUser:(PFUser *)aUser {
    PFUser* cellUser = [self.objects objectAtIndex:cellView.tag];
    NSIndexPath* cellPath = [NSIndexPath indexPathForRow:cellView.tag inSection:0];
    FriendCell* currentCell = (FriendCell* )[friendsTable cellForRowAtIndexPath:cellPath];
    NSLog(@"%@ user = ", cellUser.description);
    if ([currentCell.followButton isSelected]) {
        // Unfollow
        currentCell.followButton.selected = NO;
        [Utility unfollowUserEventually:cellUser];
        // [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Follow
        currentCell.followButton.selected = YES;
        [Utility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                //  [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
            } else {
                currentCell.followButton.selected = NO;
            }
        }];
    }
}


#pragma mark - ABPeoplePickerDelegate

/* Called when the user cancels the address book view controller. We simply dismiss it. */
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* Called when a member of the address book is selected, we return YES to display the member's details. */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

/* Called when the user selects a property of a person in their address book (ex. phone, email, location,...)
 This method will allow them to send a text or email inviting them to Engage.  */

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    
    if (property == kABPersonEmailProperty) {
        
        ABMultiValueRef emailProperty = ABRecordCopyValue(person,property);
        NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailProperty,identifier);
        self.selectedEmailAddress = email;
        
        if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {
            // ask user
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Invite %@",@""] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"iMessage", nil];
            actionSheet.tag = 0;
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            //[actionSheet showFromTabBar:self.tabBarController.tabBar];
        } else if ([MFMailComposeViewController canSendMail]) {
            // go directly to mail
            [self presentMailComposeViewController:email];
        } else if ([MFMessageComposeViewController canSendText]) {
            // go directly to iMessage
            [self presentMessageComposeViewController:email];
        }
        
    } else if (property == kABPersonPhoneProperty) {
        ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
        NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneProperty,identifier);
        
        if ([MFMessageComposeViewController canSendText]) {
            [self presentMessageComposeViewController:phone];
        }
    }
}

#pragma mark - MFMailComposeDelegate

/* Simply dismiss the MFMailComposeViewController when the user sends an email or cancels */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MFMessageComposeDelegate
/* Simply dismiss the MFMessageComposeViewController when the user sends a text or cancels */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0)
        // This was launched from the create message/main sheeo
    {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        if (buttonIndex == 0) {
            [self presentMailComposeViewController:self.selectedEmailAddress];
        } else if (buttonIndex == 1) {
            [self presentMessageComposeViewController:self.selectedEmailAddress];
        }
    }
    else if (actionSheet.tag == 1)
        // This was launched from the menu button
    {
        
    }
    
    
}

#pragma mark - ()

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)inviteFriendsButtonAction:(id)sender {
    ABPeoplePickerNavigationController *addressBook = [[ABPeoplePickerNavigationController alloc] init];
    addressBook.peoplePickerDelegate = self;
    
    if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {
        addressBook.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonEmailProperty], [NSNumber numberWithInt:kABPersonPhoneProperty], nil];
    } else if ([MFMailComposeViewController canSendMail]) {
        addressBook.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    } else if ([MFMessageComposeViewController canSendText]) {
        addressBook.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    }
    
    [self presentViewController:addressBook animated:YES completion:nil];
}


- (void)presentMailComposeViewController:(NSString *)recipient {
    // Create the compose email view controller
    MFMailComposeViewController *composeEmailViewController = [[MFMailComposeViewController alloc] init];
    
    // Set the recipient to the selected email and a default text
    [composeEmailViewController setMailComposeDelegate:self];
    [composeEmailViewController setSubject:@"Join me on the Engage App!"];
    [composeEmailViewController setToRecipients:[NSArray arrayWithObjects:recipient, nil]];
    [composeEmailViewController setMessageBody:@"<p>Engage now has a mobile app! Download it from the Apple store and we can share stories about engaging our city!</p><p><a href=\"http://engageYourCity.org\">Engage Your City</a></p><p><a href=\"http://engageYourCity.org\">The Engage app</a></p>" isHTML:YES];
    
    // Dismiss the current modal view controller and display the compose email one.
    // Note that we do not animate them. Doing so would require us to present the compose
    // mail one only *after* the address book is dismissed.
    [self dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:composeEmailViewController animated:NO completion:nil];
}

- (void)presentMessageComposeViewController:(NSString *)recipient {
    // Create the compose text message view controller
    MFMessageComposeViewController *composeTextViewController = [[MFMessageComposeViewController alloc] init];
    
    // Send the destination phone number and a default text
    [composeTextViewController setMessageComposeDelegate:self];
    [composeTextViewController setRecipients:[NSArray arrayWithObjects:recipient, nil]];
    [composeTextViewController setBody:@"Check out Engage! http://engageyourcity.org"];
    
    // Dismiss the current modal view controller and display the compose text one.
    // See previous use for reason why these are not animated.
    [self dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:composeTextViewController animated:NO completion:nil];
}

- (void)followUsersTimerFired:(NSTimer *)timer {
    [self.tableView reloadData];
    //[[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
