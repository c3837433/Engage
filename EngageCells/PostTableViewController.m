//
//  PostTableViewController.m
//  EngageCells
//
//  Created by Angela Smith on 2/15/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "PostTableViewController.h"
#import "Utility.h"
#import "Cache.h"
#import "PostTextCell.h"
#import "PostImageCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostTableViewController

@synthesize actionButton, segmentedControl, controlItems;

#pragma mark - Parse Methods
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
    // If this is not the current user, do not return anythign
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if (![PFUser currentUser])
    {
        [query setLimit:0];
        return query;
    }
    // Find all stories on Parse
    PFQuery* followingActivitiesQuery = [PFQuery queryWithClassName:@"Activity"];
    //NSLog(@"Current selection = %ld", (long)segmentedControl.selectedSegmentIndex);
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            [query includeKey:@"author"];
            [query includeKey:@"Group"];
            [query orderByDescending:@"createdAt"];
            // remove any stories that are flagged
            [query whereKeyDoesNotExist:@"Flagged"];
            return query;
            break;
        case 1:
            // Find who the user follows
            //PFQuery* followingActivitiesQuery = [PFQuery queryWithClassName:@"Activity"];
            [followingActivitiesQuery whereKey:@"activityType" equalTo:@"follow"];
            [followingActivitiesQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
            followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
            followingActivitiesQuery.limit = 1000;
            
            // Get the user's homegroup
            PFQuery* homeGroupQuery = [PFQuery queryWithClassName:@"_User"];
            [homeGroupQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
            
            // Get stories from homegroup
            PFQuery* homeGroupStoryQuery = [PFQuery queryWithClassName:self.parseClassName];
            [homeGroupStoryQuery whereKey:@"Group" matchesKey:@"group" inQuery:homeGroupQuery];
            
            // Get all stories from users followed by the user and from the user's homegroup
            PFQuery* photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
            [photosFromFollowedUsersQuery whereKey:@"author" matchesKey:@"toUser" inQuery:followingActivitiesQuery];
            [photosFromFollowedUsersQuery whereKeyExists:@"story"];
            
            PFQuery* photosFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
            [photosFromCurrentUserQuery whereKey:@"author" equalTo:[PFUser currentUser]];
            [photosFromCurrentUserQuery whereKeyExists:@"story"];
            
            PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:homeGroupStoryQuery, photosFromFollowedUsersQuery, photosFromCurrentUserQuery, nil]];
            [query includeKey:@"author"];
            [query includeKey:@"Group"];
            [query orderByDescending:@"createdAt"];
            return query;
            break;
            
            
    }
    
    
     // If there is no network connection, we will hit the cache first.
     if (self.objects.count == 0) { // || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
     [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
     }
    
    return query;
}


- (void)viewDidLoad
{
    controlItems = @[@"Global Stories", @"Local Stories"];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Add background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBg"]];
    self.tableView.estimatedRowHeight = 180;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

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


// Reload the table when returning from comment view
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITABLEVIEW DELEGATE
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    // Get the saying for this cell
    PFObject* saying = self.objects[indexPath.row];
    // see if there is an image
    if (indexPath.row == self.objects.count)
    {
        UITableViewCell* cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    else if ([[saying objectForKey:@"media"] isEqual:@"text"]) {
       // set the post cell
        // Create a testing cell InSetPostTextCell  PostTextCell
        PostTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InSetPostTextCell"];
        if (cell != nil) {
            
            // Set the saying to the cell
            PFObject* saying = self.objects[indexPath.row];
            [cell setPost:saying];
            
            // set up hashtags
            [cell.postStoryLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
                
                // NSString* selection = [NSString stringWithFormat:@"%@ [%d,%d]: %@%@", hotWords[hotWord], (int)range.location, (int)range.length, string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
                //NSLog(@"%@", selection);
                
                NSString* selectedHotWord = [NSString stringWithFormat:@"%@", hotWords[hotWord]];
                NSString* word = [NSString stringWithFormat:@"%@%@", string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
                
                [self alertUserWithSelection:selectedHotWord word:word];
                
            }];
        }
        return cell;
    } else {
        // set the image cell  InSetPostMediaCell PostImageCell
        PostImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InSetPostMediaCell"];
        if (cell != nil) {
            // set the story
            [cell setPost:saying];
            // and the image
            [cell setPostImageFrom:saying];
            // and up hashtags
            [cell.postStoryLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
                
                // NSString* selection = [NSString stringWithFormat:@"%@ [%d,%d]: %@%@", hotWords[hotWord], (int)range.location, (int)range.length, string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
                //NSLog(@"%@", selection);
                
                NSString* selectedHotWord = [NSString stringWithFormat:@"%@", hotWords[hotWord]];
                NSString* word = [NSString stringWithFormat:@"%@%@", string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
                
                [self alertUserWithSelection:selectedHotWord word:word];
                
            }];
        }
        return cell;
    }
}

-(void)alertUserWithSelection:(NSString*)type word:(NSString*)word {
    NSString* alertTitle = [NSString stringWithFormat:@"You Tapped the %@", type];
    [[[UIAlertView alloc] initWithTitle:alertTitle message:word delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
        segmentedControl.showsCount = NO;
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

- (void)refreshSegments:(id)sender
{
    [self.control removeAllSegments];
    [self.control setItems:controlItems];
}



- (void)selectedSegment:(DZNSegmentedControl *)control
{
    // [self.tableView reloadData];
    [self loadObjects];
}


#pragma mark - UIBarPositioningDelegate Methods

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)view
{
    return UIBarPositionBottom;
}

@end
