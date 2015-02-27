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

@interface UserDetailsViewController ()

@end

@implementation UserDetailsViewController
@synthesize  segmentedControl, controlItems, thisUser;

#pragma mark - PARSE METHODS
// Storyboard init
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithStyle:UITableViewStylePlain];
    self = [super initWithClassName:@"Testimonies"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = @"Testimonies";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of user stories to show per page
        self.objectsPerPage = 5;
    }
    return self;
}


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

// Search parse for Stories to be displayed withing the table
- (PFQuery *)queryForTable {

    // Find all people the user is following
    PFQuery* followingActivitiesQuery = [PFQuery queryWithClassName:aActivityClass];
    // and the ones following them
    PFQuery* followersActivitiesQuery = [PFQuery queryWithClassName:aActivityClass];
    // Find all stories on Parse
    PFQuery* query = [PFQuery queryWithClassName:self.parseClassName];
    //NSLog(@"Current selection = %ld", (long)segmentedControl.selectedSegmentIndex);
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
            // Find who the user follows
            [followingActivitiesQuery whereKey:@"activityType" equalTo:@"follow"];
            [followingActivitiesQuery whereKey:@"fromUser" equalTo:thisUser];
            followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
            followingActivitiesQuery.limit = 1000;
            
            [followingActivitiesQuery includeKey:@"fromUser"];
            [followingActivitiesQuery includeKey:@"toUser"];
            [followingActivitiesQuery orderByDescending:@"createdAt"];
            return followingActivitiesQuery;
            break;
        case 2:
            // find all followers of this user
            [followersActivitiesQuery whereKey:@"activityType" equalTo:@"follow"];
            [followersActivitiesQuery whereKey:@"toUser" equalTo:thisUser];
            followersActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
            followersActivitiesQuery.limit = 1000;
            [followersActivitiesQuery includeKey:@"fromUser"];
            [followersActivitiesQuery includeKey:@"toUser"];
            [followersActivitiesQuery orderByDescending:@"createdAt"];
            return followersActivitiesQuery;
            break;
    }
    
    
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

#pragma mark - VIEW CONTROLLER METHODS

- (void)viewDidLoad
{
    controlItems = @[@"Stories", @"Following", @"Followers"];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewDidLoad];
    
    // see if we came from the panel or another view
    // see what sent the view over
    if (!self.fromPanel) {
        // remove side button
       // NSLog(@"This is not from the panel");
        NSString* thisUserId = [self.thisUser objectId];
        NSString* currentUserId = [[PFUser currentUser] objectId];
        if ([thisUserId isEqualToString:currentUserId]) {
          //  NSLog(@"We have the current user viewing their profile");
            self.thisUser = [PFUser currentUser];
        }
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = NO;
    } else {
      //  NSLog(@"This is from the panel");
        thisUser = [PFUser currentUser];
        UIBarButtonItem* menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleDone target:self action:@selector(presentLeftMenuViewController:)];
        menuButton.image = [UIImage imageNamed:@"menu"];
        self.navigationItem.leftBarButtonItem = menuButton;
       // self.navigationItem.hidesBackButton = YES;
    }
    // set this user's data in the view
    [self setUpUserDetails];
    // Do any additional setup after loading the view.
    // Add background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBg"]];
    self.tableView.estimatedRowHeight = 180;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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
     //   [self updateUserProfileInfo];
    //    [headerView setNeedsDisplay];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
}

-(void)updateUserCounts {
    
    // Get the number of posts by this user for the first segment
    PFQuery* postsCountQuery = [PFQuery queryWithClassName:aPostClass];
    [postsCountQuery whereKey:aPostAuthor equalTo:thisUser];
    [postsCountQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [postsCountQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [segmentedControl setCount:@(number) forSegmentAtIndex:0];
            NSString* title = (number == 1) ? @"Story" : @"Stories";
            [segmentedControl setTitle:[NSString stringWithFormat:@"%@", title] forSegmentAtIndex:0];
            [[Cache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:thisUser];
        }
    }];
    // get the number of followers for the second segment
    PFQuery* queryFollowerCount = [PFQuery queryWithClassName:aActivityClass];
    [queryFollowerCount whereKey:aActivityType equalTo:aActivityFollow];
    [queryFollowerCount whereKey:aActivityToUser equalTo:thisUser];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [segmentedControl setCount:@(number) forSegmentAtIndex:1];
            NSString* title = (number == 1) ? @"Follower" : @"Followers";
            [segmentedControl setTitle:[NSString stringWithFormat:@"%@", title] forSegmentAtIndex:0];
        }
    }];
    // and the number of people the user is following
    PFQuery* queryFollowingCount = [PFQuery queryWithClassName:aActivityClass];
    [queryFollowingCount  whereKey:aActivityType equalTo:aActivityFollow];
    [queryFollowingCount whereKey:aActivityFromUser equalTo:thisUser];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [segmentedControl setCount:@(number) forSegmentAtIndex:1];
            [segmentedControl setTitle:@"Following" forSegmentAtIndex:0];
        }
    }];

}

-(void) setUpUserDetails{
    // Set name button properties and avatar image
    if ([thisUser objectForKey:aUserImage]) {
        // NSLog(@"The author HAS profile image");
        PFFile* imageFile = [thisUser objectForKey:aUserImage];
        if ([imageFile isDataAvailable]) {
            self.profilePicView.file = imageFile;
            [self.profilePicView loadInBackground];
        } else {
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

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITABLEVIEW DELEGATE AND DATA SOURCE METHODS
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    // If more stories are available
    if (indexPath.row == self.objects.count)
    {
        UITableViewCell* cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    else if ([[object objectForKey:@"media"] isEqual:@"text"]) {
        // Check what type of story we have
      //  NSString* mediaType = [object objectForKey:@"media"];
        // If it is a text, use the dext cell
        //if ([mediaType isEqualToString:@"text"]) {
            ProfileTextStoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"profileTextCell"];
            if (cell != nil) {
                [cell setProfileTextStory:object];
            }
            return cell;
        }
        // Otherwise use the media cell
        else {
            ProfileMediaStoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"profileMediaCell"];
            if (cell != nil) {
                [cell setProfileTextStory:object];
                [cell setProfileMediaStory:object];
            }
            return cell;
        }
    //}
    //return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (!segmentedControl)
    {
        segmentedControl = [[DZNSegmentedControl alloc] initWithItems:controlItems];
        segmentedControl.delegate = self;
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.showsGroupingSeparators = YES;
        segmentedControl.inverseTitles = YES;
        segmentedControl.tintColor = [UIColor darkGrayColor];
        segmentedControl.hairlineColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1];
        segmentedControl.showsCount = YES;
        segmentedControl.autoAdjustSelectionIndicatorWidth = NO;
        segmentedControl.adjustsFontSizeToFitWidth = YES;
        segmentedControl.height = 40.0f;
        [segmentedControl addTarget:self action:@selector(selectedSegment:) forControlEvents:UIControlEventValueChanged];
    }
    return segmentedControl;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    // Get and return the load more cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
            NSLog(@"Passing a text story: %@", selectedStory);
            TextCommentDetailViewController* textVC = [self.storyboard instantiateViewControllerWithIdentifier:@"textDetailVC"];
            textVC.thisStory = selectedStory;
            [self.navigationController pushViewController:textVC animated:YES];
        } else {
            // open media view
            NSLog(@"Passing a media story");
            MediaCommentDetailViewController* mediaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mediaCommntDetail"];
            mediaVC.thisStory = selectedStory;
            [self.navigationController pushViewController:mediaVC animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
 
#pragma mark - HOTWORDS LABEL SELECTION

-(void)alertUserWithSelection:(NSString*)type word:(NSString*)word {
    NSString* alertTitle = [NSString stringWithFormat:@"You Tapped the %@", type];
    [[[UIAlertView alloc] initWithTitle:alertTitle message:word delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark SEGMENTED CONTROL METHODS
- (DZNSegmentedControl *)control
{
    if (!segmentedControl)
    {
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


- (void)refreshSegments:(id)sender
{
    [self.control removeAllSegments];
    [self.control setItems:controlItems];
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

-(void) viewController:(UIViewController *)viewController returnPostSaved:(BOOL)saved {
   // NSLog(@"Returned from post with saved %d", saved);
    if (saved) {
        [self setEditing:NO animated:YES];
        [self loadObjects];
    }
}





@end
