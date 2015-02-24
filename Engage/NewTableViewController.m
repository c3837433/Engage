//
//  NewTableViewController.m
//  EngageCells
//
//  Created by Angela Smith on 1/29/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//
#import "NewTableViewController.h"
#import "Utility.h"
#import "Cache.h"
#import "DynamicLabelCell.h"


@interface NewTableViewController ()

@end

@implementation NewTableViewController

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
        self.objectsPerPage = 15;
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

    /*
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0) { // || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
     */
    return query;
}


- (void)viewDidLoad
{
    controlItems = @[@"Global Stories", @"Local Stories"];

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    // Create a testing cell
    DynamicLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DynamicCell"];
    if (cell != nil)
    {
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
}

-(void)alertUserWithSelection:(NSString*)type word:(NSString*)word {
    NSString* alertTitle = [NSString stringWithFormat:@"You Tapped the %@", type];
     [[[UIAlertView alloc] initWithTitle:alertTitle message:word delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.objects.count;
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // See what cell we are in
    if (indexPath.row == self.objects.count) {
        // This is a cell for the next row of items
        return 40.0f;
    } else {
        // Get the current post
        PFObject* postObject = [self.objects objectAtIndex:indexPath.row];
        bool hasImage = YES;
        if ([[postObject objectForKey:@"media"] isEqual:@"text"]) {
            hasImage = NO;
        }
        // and the text of the saying
        NSString* sayingText = [postObject objectForKey:aPostText];
        // Define the label font
        UIFont* font = [UIFont fontWithName:aFont size:14];
        
        // Get the width of the label by taking the cell and subtracting the side margins
        CGFloat labelWidth = tableView.frame.size.width - 16;
        // Create an attributed string from the text so we can create the shape
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:sayingText attributes:@{NSFontAttributeName: font}];
        // Create a rect that would fit the text label
        CGRect labelRect = [attributedText boundingRectWithSize:(CGSize){labelWidth, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        // Get the size, then the height
        CGSize labelSize = labelRect.size;
        labelSize.height = ceilf(labelSize.height);
        if (hasImage) {
            return labelSize.height + 305;
        } else {
            // return the height needed for the label plus the base tableview cell height
            return labelSize.height + 177;
        }
        
    }
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

