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

@interface UserDetailsViewController ()
//@property (nonatomic, strong) DZNSegmentedControl *control;
@property (nonatomic, strong) NSArray* userIsFollowingArray;
@property (nonatomic, strong) NSArray* isFollowingUserArray;
typedef void (^ArrayResponseBlock)(NSArray* followerArray);
typedef void (^ArrayResponseBlock)(NSArray* followingArray);

//@property (nonatomic, strong) NSMutableDictionary *outstandingFollowQueries;

@end

@implementation UserDetailsViewController
@synthesize /* segmentedControl, controlItems,*/ thisUser;

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

/*
+ (void)load
{
    if (!_allowAppearance) {
        return;
    }
    
    [[DZNSegmentedControl appearance] setBackgroundColor:[UIColor redColor]];
    [[DZNSegmentedControl appearance] setTintColor:[UIColor purpleColor]];
    [[DZNSegmentedControl appearance] setHairlineColor:[UIColor yellowColor]];
    
    [[DZNSegmentedControl appearance] setFont:[UIFont fontWithName:aFont size:15.0]];
    [[DZNSegmentedControl appearance] setSelectionIndicatorHeight:2.5];
    [[DZNSegmentedControl appearance] setAnimationDuration:0.125];
    [[DZNSegmentedControl appearance] setHeight:40.0f];
}
*/
// Search parse for Stories to be displayed withing the table
- (PFQuery *)queryForTable {
    
   // PFQuery* userQuery = [PFUser query];
    // Find all stories on Parse
    PFQuery* query = [PFQuery queryWithClassName:self.parseClassName];
    // If this is not the current user, do not return anythign
   // NSMutableArray* followers = [[NSMutableArray alloc] init];
    //PFQuery *followeesQuery = [PFQuery queryWithClassName:aActivityClass];
    [query whereKey:@"author" equalTo:self.thisUser];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    [query includeKey:@"group"];
   // return query;
    /*
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
             // Find posts for the selected user
             if (self.thisUser == nil) {
                 self.thisUser = [PFUser currentUser];
             }
             [query whereKey:@"author" equalTo:self.thisUser];
             [query orderByDescending:@"createdAt"];
             [query includeKey:@"author"];
             [query includeKey:@"group"];
             return query;
            break;
        case 1:
            // people the user is following
            [userQuery whereKey:@"idString" containedIn:self.userIsFollowingArray];
            NSLog(@"User is following: %@", self.userIsFollowingArray.description);
            [userQuery includeKey:@"group"];
            return userQuery;
            break;
        case 2:
            // people following the user
            [userQuery whereKey:@"objectId" containedIn:self.isFollowingUserArray];
            NSLog(@"User following this user: %@", self.isFollowingUserArray.description);
            [userQuery includeKey:@"group"];
            return userQuery;

            break;
    }
    
    */
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSLog(@"Zero objects found and we are connected to parse");
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return query;
}
/*
#pragma mark - VIEW CONTROLLER METHODS

- (void) getAllFollowersAsyncWithCompletion:(ArrayResponseBlock)completionBlock {
    
    NSMutableArray* followersArray = [NSMutableArray array];
    PFQuery* activityQuery = [PFQuery queryWithClassName:aActivityClass];
        [activityQuery whereKey:aActivityFromUser equalTo:self.thisUser];
    [activityQuery whereKey:aActivityType equalTo:aActivityFollow];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray* follows, NSError * error) {
        for (PFObject* follow in follows) {
            PFUser* follower = [follow objectForKey:aActivityToUser];
            [followersArray addObject:follower];
        }
        
        completionBlock(followersArray);
    }];
}

- (void) getAllFollowingAsyncWithCompletion:(ArrayResponseBlock)completionBlock {
    
    NSMutableArray* followingArray = [NSMutableArray array];
    PFQuery* activityQuery = [PFQuery queryWithClassName:aActivityClass];
    [activityQuery whereKey:aActivityToUser equalTo:self.thisUser];
    [activityQuery whereKey:aActivityType equalTo:aActivityFollow];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray* follows, NSError * error) {
        for (PFObject* follow in follows) {
            PFUser* follower = [follow objectForKey:aActivityFromUser];
            [followingArray addObject:follower];
        }
        
        completionBlock(followingArray);
    }];
}
*/
- (void)viewDidLoad {
    /*
    [self getAllFollowersAsyncWithCompletion:^(NSArray* followerArray) {
        self.isFollowingUserArray = followerArray;
        NSLog(@"Retrieved all followers");
    }];
    [self getAllFollowingAsyncWithCompletion:^(NSArray* followingArray) {
        NSLog(@"retrieved all people user is following");
        self.userIsFollowingArray = followingArray;
    }];
    
    controlItems = @[@"Stories", @"Following", @"Followers"]; */
    [[PFUser currentUser] fetchIfNeededInBackground];
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
    // set up the rounded corners on the imageview
    self.profilePicView.layer.cornerRadius = 8.0;
    self.profilePicView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.profilePicView.layer.borderWidth = 2.0;
    self.profilePicView.layer.masksToBounds = YES;
    // set this user's data in the view
    [self setUpUserDetails];
    // Do any additional setup after loading the view.
    // Add background image
  //  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBg"]];
   // self.tableView.estimatedRowHeight = 180;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
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
/*
- (void)updateControlCounts {
    NSLog(@"Updating control counts");
    NSNumber* postCount = 0;
    NSNumber* followerCount = 0;
    NSNumber* followingCount = 0;
    [thisUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        thisUser = (PFUser*) object;
    }];
    // get post count
    if ([thisUser objectForKey:@"Posts"]) {
        // get the posts
        int posts = [[thisUser objectForKey:@"Posts"] intValue];
        NSLog(@"User has %d posts", posts);
        postCount = [NSNumber numberWithInt:posts];
        NSLog(@"Post count number = %@", postCount);
    }
    // get follower count
    if ([thisUser objectForKey:@"Followers"]) {
        int followers = [[thisUser objectForKey:@"Followers"] intValue];
         NSLog(@"User has %d followers", followers);
        followerCount = [NSNumber numberWithInt:followers];
    }
    
    // get following count
    if ([thisUser objectForKey:@"Following"]) {
        // get the comment count
        int following = [[thisUser objectForKey:@"Following"] intValue];
         NSLog(@"User has %d users following", following);
        followingCount = [NSNumber numberWithInt:following];
    }
    [self.control setCount:postCount forSegmentAtIndex:0];
    [self.control setCount:followingCount forSegmentAtIndex:1];
    [self.control setCount:followerCount forSegmentAtIndex:2];

}
*/

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
            [self.homeGroupButton setTitle:[group objectForKey:aPostAuthorGroupTitle] forState:UIControlStateNormal];
            [self.homeGroupButton setTitle:[group objectForKey:aPostAuthorGroupTitle] forState:UIControlStateHighlighted];
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

        /*
        if (segmentedControl.selectedSegmentIndex == 0) {
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
        } else {
            // this is a user cell
            FriendCell* cell = [tableView dequeueReusableCellWithIdentifier:@"followFriendCell"];
            if (cell != nil) {
                PFUser* user = (PFUser*) object;
                NSLog(@"This user: %@", user.description);
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
        }  */
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
      return self.control;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    // Get and return the load more cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.objects.count) {
        return 45;
    } //else {
    return 100;
    //}
  // if (self.segmentedControl.selectedSegmentIndex == 0) {
       // return 100;
   // }else {
     //   return 45;
    //}
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

/*
#pragma mark SEGMENTED CONTROL METHODS
- (DZNSegmentedControl *)control
{
    if (!segmentedControl)
    {
        segmentedControl = [[DZNSegmentedControl alloc] initWithItems:controlItems];
        segmentedControl.delegate = self;
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.showsGroupingSeparators = YES; //
        segmentedControl.inverseTitles = YES; //
        segmentedControl.tintColor = [UIColor darkGrayColor];
        segmentedControl.hairlineColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1];
        segmentedControl.showsCount = YES;
        segmentedControl.autoAdjustSelectionIndicatorWidth = NO; //
       // segmentedControl.adjustsFontSizeToFitWidth = YES; //
        segmentedControl.height = 55.0f;
        segmentedControl.font = [UIFont fontWithName:aFont size:15.0];

        [segmentedControl addTarget:self action:@selector(selectedSegment:) forControlEvents:UIControlEventValueChanged];
    }
    return segmentedControl;
}


- (void)refreshSegments:(id)sender
{
    [self.control removeAllSegments];
    [self.control setItems:controlItems];
   // [self updateControlCounts];
}


- (void)selectedSegment:(DZNSegmentedControl *)control
{
    [self loadObjects];
}

// UIBarPositioningDelegate for segmented control

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)view
{
    return UIBarPositionBottom;
}
*/


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

-(void) viewController:(UIViewController *)viewController returnPostUpdated:(BOOL)updated {
    if (updated) {
        NSLog(@"Returned from edit profile with saved %d", updated);
        // need to refresh current user
        [self setUpUserDetails];
    }
}
/*
#pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
     if ([segue.identifier isEqualToString:@"segueToFollowing"]) {
         FollowFriendsViewController* vc = segue.destinationViewController;
         vc.getFollowers = true;
         vc.followersForUser = self.thisUser;
     }
 }
*/



@end
