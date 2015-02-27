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
#import "AppDelegate.h"
#import "CustomSearchViewController.h"
#import "MZCustomTransition.h"

@interface FindFriendTableViewController () <CustomSearchDelegate>

@end

@implementation FindFriendTableViewController

@synthesize  selectedEmailAddress, friendsTable, segmentedControl, controlItems;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"_User"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.parseClassName = @"_User";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of objects to show per page
        self.objectsPerPage = 7;
    }
    return self;
}

+ (void)load
{
    if (!_allowAppearance) {
        return;
    }
    [[DZNSegmentedControl appearance] setBackgroundColor:[UIColor whiteColor]];
    [[DZNSegmentedControl appearance] setTintColor:[UIColor darkGrayColor]];
    [[DZNSegmentedControl appearance] setHairlineColor:[UIColor darkGrayColor]];
    
    [[DZNSegmentedControl appearance] setFont:[UIFont fontWithName:aFont size:15.0]];
    [[DZNSegmentedControl appearance] setSelectionIndicatorHeight:2.5];
    [[DZNSegmentedControl appearance] setAnimationDuration:0.125];
    [[DZNSegmentedControl appearance] setHeight:55.0f];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    controlItems = @[@"Contacts", @"Facebook", @"Search"];
    self.tableView.tableHeaderView = self.control;
    
    // set up the custom search view
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    
    [MZFormSheetController registerTransitionClass:[MZCustomTransition class] forTransitionStyle:MZFormSheetTransitionStyleCustom];
}
/*
-(void)pullStories {
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
 */
-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
   // [self pullStories];
}

/*
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
*/
#pragma mark - PFQueryTableViewController
- (PFQuery *)queryForTable {
    // If this is not the current user, do not return anythign
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    if (![PFUser currentUser]) {
        [query setLimit:0];
        return query;
    }
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:  { // contacts
            // Find who the user follows
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
                               // NSLog(@"EMAIL: %@",email);
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
                        //NSLog(@"EMAIL: %@",email);
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
            PFQuery* query = [PFQuery orQueryWithSubqueries:@[emailQuery,nameQuery]];
            query.cachePolicy = kPFCachePolicyNetworkOnly;
            [query includeKey:@"group"];
            [query orderByAscending:@"UsersFullName"];
            [query whereKey: @"email" notEqualTo: [[PFUser currentUser] objectForKey: @"email"]];
            return query;
            break;
        }
        case 1: {  // facebook
            // Make sure the user is logged in through facebook!
            // Use cached facebook friend ids
            facebookFriends = [[Cache sharedCache] facebookFriends];
            NSLog(@"facebook friends in cache: %@", facebookFriends.description);
            // Query for all friends you have on facebook and who are using the app
           // PFQuery *friendQuery = [PFUser query];
            [query whereKey:@"facebookId" containedIn:facebookFriends];
            // findObjects will return a list of PFUsers that are friends
            query.cachePolicy = kPFCachePolicyNetworkOnly;
            [query includeKey:@"group"];
            [query orderByAscending:@"UsersFullName"];
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
                NSLog(@"No users returned ");
            } else {
                NSLog(@"Loading %lu users", (unsigned long)self.objects.count);
            }
            return query;
            break;
        }
        case 2: {
            if ((self.needSearchName == true) || ([self.searchName isEqual:@""])) {
                [query setLimit:0];
                NSLog(@"Need to display search field");
                [self getUserNameForSearch];
                return nil;
            } else {
                [query whereKey:@"UsersFullName" containsString:self.searchName];
                [query includeKey:@"group"];
                if (self.objects.count == 0) {
                    NSLog(@"No users returned by that name");
                }
                // reset the values
                self.searchName = @"";
                self.needSearchName = true;
                return query;
            }
            break;
        }
    }
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return query;
}
-(void) getUserNameForSearch {
    NSLog(@"We need to display search bar");
    
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"customFriendSearch"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    CustomSearchViewController* customControl = (CustomSearchViewController*) vc.topViewController;
    customControl.delegate = self;
    
    formSheet.presentedFormSheetSize = CGSizeMake(300, 150);
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    __weak MZFormSheetController *weakFormSheet = formSheet;
    
    
    // If you want to animate status bar use this code
    formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
        UINavigationController *navController = (UINavigationController *)weakFormSheet.presentedFSViewController;
        if ([navController.topViewController isKindOfClass:[CustomSearchViewController class]]) {
            CustomSearchViewController *mzvc = (CustomSearchViewController *)navController.topViewController;
            mzvc.showStatusBar = NO;
        }
        
        
        [UIView animateWithDuration:0.3 animations:^{
            if ([weakFormSheet respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [weakFormSheet setNeedsStatusBarAppearanceUpdate];
            }
        }];
    };
    formSheet.transitionStyle = MZFormSheetTransitionStyleCustom;
    
    [MZFormSheetController sharedBackgroundWindow].formSheetBackgroundWindowDelegate = self;
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}


-(void) viewController:(UIViewController *)vC returnSearchString:(NSString *)searchString {
    self.searchName = searchString;
    self.needSearchName = NO;
    [self loadObjects];
}



-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {

    static NSString *FriendCellIdentifier = @"followFriendCell";
    FriendCell* cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell != nil) {
        cell.delegate = self;
        [cell setUser:(PFUser*)object];
        cell.followButton.tag = indexPath.row;
        // Set the default stories
        // get the people the user already follows
        NSDictionary *attributes = [[Cache sharedCache] attributesForUser:(PFUser *)object];
        if (attributes) {
            // set them accordingly
            [cell.followButton setSelected:[[Cache sharedCache] followStatusForUser:(PFUser *)object]];
        }
        cell.followButton.selected = NO;
        cell.followButton.tag = indexPath.row;
        cell.tag = indexPath.row;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!segmentedControl) {
        segmentedControl = [[DZNSegmentedControl alloc] initWithItems:controlItems];
        segmentedControl.delegate = self;
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.showsGroupingSeparators = YES;
        segmentedControl.inverseTitles = YES;
        segmentedControl.tintColor = [UIColor darkGrayColor];
        segmentedControl.hairlineColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1];
        segmentedControl.showsCount = NO;
        segmentedControl.autoAdjustSelectionIndicatorWidth = NO;
        segmentedControl.adjustsFontSizeToFitWidth = YES;
        segmentedControl.height = 55.0f;
        [segmentedControl addTarget:self action:@selector(selectedSegment:) forControlEvents:UIControlEventValueChanged];
    }
    return segmentedControl;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
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

// Called when the user cancels the address book view controller. We simply dismiss it.
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Called when a member of the address book is selected, we return YES to display the member's details.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

//Called when the user selects a property of a person in their address book (ex. phone, email, location,...)
 //This method will allow them to send a text or email inviting them to Engage.

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

// Simply dismiss the MFMailComposeViewController when the user sends an email or cancels
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MFMessageComposeDelegate
//Simply dismiss the MFMessageComposeViewController when the user sends a text or cancels
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

#pragma mark SEGMENTED CONTROL METHODS
- (DZNSegmentedControl *)control {
    if (!segmentedControl) {
        segmentedControl = [[DZNSegmentedControl alloc] initWithItems:controlItems];
        segmentedControl.delegate = self;
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.showsGroupingSeparators = YES;
        segmentedControl.inverseTitles = YES;
        segmentedControl.tintColor = [UIColor darkGrayColor];
        segmentedControl.hairlineColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1];
        segmentedControl.showsCount = NO;
        segmentedControl.autoAdjustSelectionIndicatorWidth = NO;
        segmentedControl.adjustsFontSizeToFitWidth = YES;
        [segmentedControl addTarget:self action:@selector(selectedSegment:) forControlEvents:UIControlEventValueChanged];
    }
    return segmentedControl;
}


- (void)refreshSegments:(id)sender {
    [self.control removeAllSegments];
    [self.control setItems:controlItems];
}


- (void)selectedSegment:(DZNSegmentedControl *)control {
    [self loadObjects];
}


#pragma mark UIBARPOSITIONING DELEGATE FOR SEGMENTED CONTROL
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)view {
    return UIBarPositionBottom;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
