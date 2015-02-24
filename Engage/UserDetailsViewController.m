//
//  UserDetailsViewController.m
//  Engage
//
//  Created by Angela Smith on 2/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "UserDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ApplicationKeys.h"
#import "Cache.h"
#import "ProfileMediaStoryCell.h"
#import "ProfileTextStoryCell.h"
#import "AppDelegate.h"
#import "ApplicationKeys.h"

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
           // [query includeKey:@"author"];
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
    if (self.fromPanel == false) {
        // remove side button
        NSLog(@"This is not from the panel");
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = NO;
    } else {
        NSLog(@"This is from the panel");
    }
    // set this user's data in the view
    [self setUpUserDetails];
    // Do any additional setup after loading the view.
    // Add background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBg"]];
    self.tableView.estimatedRowHeight = 180;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    // If more stories are available
    if (indexPath.row == self.objects.count)
    {
        // Get the load more cell
        UITableViewCell* loadMoreCell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return loadMoreCell;
    }
    else
    {
        // Check what type of story we have
        NSString* mediaType = [object objectForKey:@"media"];
        // If it is a text, use the dext cell
        if ([mediaType isEqualToString:@"text"])
        {
            ProfileTextStoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"profileTextCell"];
            if (cell != nil)
            {
                [cell setProfileTextStory:object];
            }
            return cell;
        }
        // Otherwise use the media cell
        else
        {
            ProfileMediaStoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"profileMediaCell"];
            if (cell != nil)
            {
                // Set the remaining object details
                [cell setProfileMediaStory:object];
            }
            return cell;
        }
    }
    return nil;
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


#pragma mark - Segue Methods //textCommentSegue  postImageSegueToComment
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton*)sender
{
    if ([segue.identifier isEqualToString:@"textCommentSegue"])
    {
     //   PFObject* story = [self.objects objectAtIndex:sender.tag];
      //  AddStoryCommentViewController* addCommentVC = segue.destinationViewController;
        //addCommentVC.thisStory = story;
    }
    else if ([segue.identifier isEqualToString:@"postTextSegueToComment"])
    {
       // PFObject* story = [self.objects objectAtIndex:sender.tag];
       // AddStoryCommentViewController* addCommentVC = segue.destinationViewController;
       // addCommentVC.thisStory = story;
    }
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






@end
