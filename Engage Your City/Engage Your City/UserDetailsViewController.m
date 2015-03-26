//
//  UserDetailsViewController.m
//  Engage
//
//  Created by Angela Smith on 2/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//
#import "RESideMenu.h"
#import "UserDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ApplicationKeys.h"
#import "Cache.h"
#import "ProfileMediaStoryCell.h"
#import "ProfileTextStoryCell.h"
#import "AppDelegate.h"
#import "ApplicationKeys.h"
#import <Parse/Parse.h>
#import "TextCommentDetailViewController.h"
#import "MediaCommentDetailViewController.h"
#import "FriendCell.h"
#import "ApplicationKeys.h"
#import "FollowFriendsViewController.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>
#import "GroupDetailViewController.h"

@interface UserDetailsViewController ()
@property (nonatomic, strong) NSArray* userIsFollowingArray;
@property (nonatomic, strong) NSArray* isFollowingUserArray;
typedef void (^ArrayResponseBlock)(NSArray* followerArray);
typedef void (^ArrayResponseBlock)(NSArray* followingArray);

@end

@implementation UserDetailsViewController
@synthesize thisUser;

#pragma mark - PARSE METHODS
// Storyboard init
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithStyle:UITableViewStylePlain];
    //self = [super initWithClassName:@"Testimonies"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = @"Testimonies";
        // Whether the built-in pull-to-refresh is enabled
        self.userIsFollowingArray = [[NSArray alloc] init];
        self.isFollowingUserArray = [[NSArray alloc] init];

        self.pullToRefreshEnabled = YES;
        // The number of user stories to show per page
        self.objectsPerPage = 5;
    }
    return self;
}


// Search parse for Stories to be displayed withing the table
- (PFQuery *)queryForTable {

    if (!self.fromPanel) {
        NSLog(@"Not from panel");
    } else {
        NSLog(@"This is from the panel, setting profile for current user");
        self.thisUser = [PFUser currentUser];
    }
    // Find all stories on Parse
    PFQuery* query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"author" equalTo:self.thisUser];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    [query includeKey:@"group"];

    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    }
    return query;
}

- (void)viewDidLoad {

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewDidLoad];
    
    // see if we came from the panel or another view
    // see what sent the view over
    if (!self.fromPanel) {
        // remove side button
       // NSLog(@"This is not from the panel");
        self.userId = [self.thisUser objectId];
         NSLog(@"this user id = %@", self.userId);
        NSString* currentUserId = [[PFUser currentUser] objectId];
        if ([self.userId isEqualToString:currentUserId]) {
          //  NSLog(@"We have the current user viewing their profile");
            self.thisUser = [PFUser currentUser];
        }
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = NO;
    } else {
      //  NSLog(@"This is from the panel");
        thisUser = [PFUser currentUser];
        self.userId = [thisUser objectForKey:@"idString"];
        NSLog(@"this user id = %@", self.userId);
        UIBarButtonItem* menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleDone target:self action:@selector(presentLeftMenuViewController:)];
        menuButton.image = [UIImage imageNamed:@"menu"];
        self.navigationItem.leftBarButtonItem = menuButton;
       // self.navigationItem.hidesBackButton = YES;
    }
    [self.thisUser fetchIfNeededInBackground];
    // set up the rounded corners on the imageview
    self.profilePicView.layer.cornerRadius = 8.0;
    self.profilePicView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.profilePicView.layer.borderWidth = 2.0;
    self.profilePicView.layer.masksToBounds = YES;
    // set this user's data in the view
    [self setUpUserDetails];

}

// DELETE ITEM IN TABLEVIEW
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![PFUser currentUser]) {
        [self setEditing:NO animated:YES];
    }
}


- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    // get the selected item
    self.selectedStory = [self.objects objectAtIndex:indexPath.row];
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
       // NSLog(@"User wants to edit story");
        [self openPostToEdit];
    }];
    editAction.backgroundColor = [UIColor lightGrayColor];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
      //  NSLog(@"User wants to delete story");
        [[[UIAlertView alloc] initWithTitle:@"Confirm Delete?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil] show];
    }];
    
    return @[deleteAction, editAction];
}

// If the user gave permission, change the default and store that value as a PFUser value
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
 if (buttonIndex == 1) {
     // User wants to delete item
     [self.selectedStory deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         if (succeeded) {
             // reload objects
             [self loadObjects];
             self.selectedStory = nil;
         }
     }];
 }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Setting editing style");
    if (thisUser == [PFUser currentUser]) {
        //NSLog(@"This is the current user");
        return UITableViewCellEditingStyleDelete;
    } else {
        //NSLog(@"This is not the current user");
        return UITableViewCellEditingStyleNone;
    }
}

// Reload the table when returning from comment view
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;

    // Add shadow to bottom of detail view
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.detailsView.bounds];
    self.detailsView.layer.masksToBounds = NO;
    self.detailsView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.detailsView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.detailsView.layer.shadowOpacity = 0.5f;
    self.detailsView.layer.shadowPath = shadowPath.CGPath;
   // [self.tableView reloadData];
   // [self updateControlCounts];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
}


-(void) setUpUserDetails {
    // Set name button properties and avatar image
    if ([thisUser objectForKey:aUserImage]) {
        // NSLog(@"The author HAS profile image");
        PFFile* imageFile = [thisUser objectForKey:aUserImage];
        if ([imageFile isDataAvailable]) {
            self.fullbgPicView.file = imageFile;
            [self.fullbgPicView loadInBackground];
            self.profilePicView.file = imageFile;
            [self.profilePicView loadInBackground];
        } else {
            self.fullbgPicView.file = imageFile;
            [self.fullbgPicView loadInBackground];
            self.profilePicView.file = imageFile;
            [self.profilePicView loadInBackground];
        }
    } else {
        self.profilePicView.image = [UIImage imageNamed:@"placeholder"];
    }
    
    // SET AUTHOR NAME
    self.userNameLabel.text = [thisUser objectForKey:aUserName];

    // SET LOCAL GROUP
    if ([thisUser objectForKey:aUserGroup]) {
        PFObject* group = [thisUser objectForKey:aUserGroup];
        [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.homeGroupButton setTitle:[group objectForKey:aHomeGroupTitle] forState:UIControlStateNormal];
            [self.homeGroupButton setTitle:[group objectForKey:aHomeGroupTitle] forState:UIControlStateHighlighted];
            // add button click to open this group page up
        }];
    } else {
        self.homeGroupButton.hidden = YES;
    }
    
    // POSTS
    if ([thisUser objectForKey:@"Posts"]) {
        // get the posts
        int posts = [[thisUser objectForKey:@"Posts"] intValue];
        self.userPostCountLabel.text = [NSString stringWithFormat:@"%d Testimonies", posts];
    } else {
        self.userPostCountLabel.text = [NSString stringWithFormat:@"0 Testimonies"];
    }
    
    // FOLLOWS
    int followers = 0;
    int following = 0;
    NSString* followingString = @"Following";
    NSString* followerString = @"Followers";
    // get follower count
    if ([thisUser objectForKey:@"Followers"]) {
        followers = [[thisUser objectForKey:@"Followers"] intValue];
        NSLog(@"User has %d followers", followers);
        followerString = (followers == 1) ? @"Follower" : @"Followers";
        
    }
    // get following count
    if ([thisUser objectForKey:@"Following"]) {
        // get the comment count
        following = [[thisUser objectForKey:@"Following"] intValue];
        NSLog(@"User has %d users following", following);
    }
    self.userFollowLabel.text = [NSString stringWithFormat:@"%d %@  |  %d %@", followers, followerString, following, followingString];
    
    // LOCATION
    if ([thisUser objectForKey:@"Location"]) {
        self.userLocationLabel.text = [thisUser objectForKey:@"Location"];
    } else {
        self.userLocationLabel.text = @"";
    }
    
    // ABOUT ME
    if ([thisUser objectForKey:aUserAboutMe]) {
        self.userAboutMeLabel.text = [thisUser objectForKey:aUserAboutMe];
    } else {
        self.userAboutMeLabel.text = @"";
    }
    
    NSString* currentUserId = [[PFUser currentUser] objectId];
    if ([self.userId isEqualToString:currentUserId]) {
        self.thisUser = [PFUser currentUser];
        // Set the button to EDIT PROFILE
        NSLog(@"This is the current user, need to enable edit mode");
        [self.followEditButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
        [self.followEditButton setTitle:@"Edit Profile" forState:UIControlStateHighlighted];

    } else {
        NSLog(@"This is a different user, need to check to see if we are following them");
        NSDictionary *attributes = [[Cache sharedCache] attributesForUser:self.thisUser];
        if (attributes) {
            NSLog(@"Found attributes");
            // set them accordingly
            [self.followEditButton setSelected:[[Cache sharedCache] followStatusForUser:self.thisUser]];
        } else {
            @synchronized(self) {
                NSLog(@"Getting Attributes");
                PFQuery *isFollowingQuery = [PFQuery queryWithClassName:aActivityClass];
                [isFollowingQuery whereKey:aActivityFromUser equalTo:[PFUser currentUser]];
                [isFollowingQuery whereKey:aActivityType equalTo:aActivityFollow];
                [isFollowingQuery whereKey:aActivityToUser equalTo:self.thisUser];
                [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                
                [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    @synchronized(self) {
                        [[Cache sharedCache] setFollowStatus:(!error && number > 0) user:self.thisUser];
                    }
                    [self.followEditButton setSelected:(!error && number > 0)];
                }];
            }
        }
    
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITABLEVIEW DELEGATE AND DATA SOURCE METHODS
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    // If more stories are available
    if (indexPath.row == self.objects.count) {
        UITableViewCell* cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    
    else {
        if ([[object objectForKey:@"media"] isEqual:@"text"]) {
            // This is a text cell
            ProfileTextStoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"profileTextCell"];
            if (cell != nil) {
                [cell setProfileTextStory:object];
            }
            return cell;
        }
        
        else {
            // Otherwise use the media cell
            ProfileMediaStoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"profileMediaCell"];
            if (cell != nil) {
                [cell setProfileTextStory:object];
                [cell setProfileMediaStory:object];
            }
            return cell;
        }
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    // Get and return the load more cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.objects.count) {
        return 45;
    }
    return 100;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.row == self.objects.count) {
        [self loadNextPage];
    } else {
        PFObject* selectedStory = [self.objects objectAtIndex:indexPath.row];
        //NSLog(@"Passing the selected story = %@", selectedStory);
        if ([[selectedStory objectForKey:@"media"] isEqualToString:@"text"]) {
            // open text view
           // NSLog(@"Passing a text story: %@", selectedStory);
            TextCommentDetailViewController* textVC = [self.storyboard instantiateViewControllerWithIdentifier:@"textDetailVC"];
            textVC.thisStory = selectedStory;
            [self.navigationController pushViewController:textVC animated:YES];
        } else {
            // open media view
            //NSLog(@"Passing a media story");
            MediaCommentDetailViewController* mediaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mediaCommntDetail"];
            mediaVC.thisStory = selectedStory;
            [self.navigationController pushViewController:mediaVC animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
 

- (IBAction)didTapFollowEditButton:(UIButton*)button {
    // Make sure this is not the current user;
    NSString* currentUserId = [[PFUser currentUser] objectId];
    if ([self.userId isEqualToString:currentUserId]) {
        NSLog(@"Editing Current User");
        [self openProfileToEdit];
    } else {
        // Follow/unfollow
        NSLog(@"%@ Following/ Unfollowing user = ", self.thisUser.description);
        if ([self.followEditButton isSelected]) {
            // Unfollow
            self.followEditButton.selected = NO;
            [Utility unfollowUserEventually:self.thisUser];
            // [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
        } else {
            // Follow
            self.followEditButton.selected = YES;
            [Utility followUserEventually:self.thisUser block:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    //  [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
                } else {
                    self.followEditButton.selected = NO;
                }
            }];
        }
    }
}


-(void) openProfileToEdit {
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"customEditProfile"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    CustomEditProfileViewController* customControl = (CustomEditProfileViewController*) vc.topViewController;
    customControl.delegate = self;

    
    formSheet.presentedFormSheetSize = CGSizeMake(320, 480);
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.shouldCenterVertically = YES;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    __weak MZFormSheetController *weakFormSheet = formSheet;
    
    
    // If you want to animate status bar use this code
    formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
        UINavigationController *navController = (UINavigationController *)weakFormSheet.presentedFSViewController;
        if ([navController.topViewController isKindOfClass:[CustomEditProfileViewController class]]) {
            CustomEditProfileViewController *mzvc = (CustomEditProfileViewController *)navController.topViewController;
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


-(void) openPostToEdit {
    //NSLog(@"We need to display edit view");
    
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"customAddPost"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    CustomAddPostViewController* customControl = (CustomAddPostViewController*) vc.topViewController;
    customControl.delegate = self;
    customControl.thisStory = self.selectedStory;
    customControl.updatingStory = true;
    
    formSheet.presentedFormSheetSize = CGSizeMake(320, 480);
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.shouldCenterVertically = YES;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    __weak MZFormSheetController *weakFormSheet = formSheet;
    
    
    // If you want to animate status bar use this code
    formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
        UINavigationController *navController = (UINavigationController *)weakFormSheet.presentedFSViewController;
        if ([navController.topViewController isKindOfClass:[CustomAddPostViewController class]]) {
            CustomAddPostViewController *mzvc = (CustomAddPostViewController *)navController.topViewController;
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
#pragma mark - Custom Edit Post or User Delegate
-(void) viewController:(UIViewController *)viewController returnPostSaved:(BOOL)saved {
   // NSLog(@"Returned from post with saved %d", saved);
    if (saved) {
        [self setEditing:NO animated:YES];
        [self loadObjects];
    }
}
- (IBAction)shouldLoadLocalGroup:(id)sender {
    GroupDetailViewController* groupDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"groupDetailVC"];
    PFObject* currentGroup = [self.thisUser objectForKey:aUserGroup];
    groupDetailVC.group = currentGroup;
    [self.navigationController pushViewController:groupDetailVC animated:YES];
}

-(void) viewController:(UIViewController *)viewController returnPostUpdated:(BOOL)updated {
    if (updated) {
        NSLog(@"Returned from edit profile with saved %d", updated);
        // need to refresh current user
        [self setUpUserDetails];
    }
}




@end
