//
//  ActivityViewController.m
//  Engage
//
//  Created by Angela Smith on 1/22/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "ActivityViewController.h"
#import "AddStoryCommentViewController.h"
#import "ProfileViewController.h"

@interface ActivityViewController ()

@property (nonatomic, strong) NSDate *lastRefresh;
@property (nonatomic, strong) UIView *blankTimelineView;

@end

@implementation ActivityViewController

@synthesize lastRefresh, blankTimelineView;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Activity"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = @"Activity";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of user stories to show per page
        self.objectsPerPage = 15;
    }
    return self;
}

- (PFQuery *)queryForTable {
    // Create query
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    // find all activity that is directed to the user
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    // find all the activity that was not created by the user
    [query whereKey:@"fromUser" notEqualTo:[PFUser currentUser]];
    // where the user is connected
    [query whereKeyExists:@"fromUser"];
    // include the poster
    [query includeKey:@"fromUser"];
    // and story object
    [query includeKey:@"Testimony"];
    // order newest first
    [query orderByDescending:@"createdAt"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

- (void)viewDidLoad {
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [super viewDidLoad];

    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    /*
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"ActivityFeedBlank.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(24.0f, 113.0f, 271.0f, 140.0f)];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
    */
    lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.Engage.userDefaults.activityviewcontroller.lastRefresh"];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.separatorColor = [UIColor colorWithRed:30.0f/255.0f green:30.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString = [ActivityViewController stringForActivityType:(NSString*)[object objectForKey:@"ActivityType"]];
        
        PFUser *user = (PFUser*)[object objectForKey:@"fromUser"];
        NSString *nameString = NSLocalizedString(@"Someone", nil);
        if (user && [user objectForKey:@"UsersFullName"] && [[user objectForKey:@"UsersFullName"] length] > 0) {
            nameString = [user objectForKey:@"UsersFullName"];
        }
        
        return [ActivityCell heightForCellWithName:nameString contentString:activityString];
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        PFObject *activity = [self.objects objectAtIndex:indexPath.row];
        if ([activity objectForKey:@"Testimony"]) {
            AddStoryCommentViewController* detailvc = [[AddStoryCommentViewController alloc] initWithStory:[activity objectForKey:@"Testimony"]];
            [self.navigationController pushViewController:detailvc animated:YES];
        } else if ([activity objectForKey:@"fromUser"]) {
            ProfileViewController *userProfileVc = [[ProfileViewController alloc] initWithStyle:UITableViewStylePlain];
            NSLog(@"Presenting account view controller with user: %@", [activity objectForKey:@"fromUser"]);
            [userProfileVc setUser:[activity objectForKey:@"fromUser"]];
            [self.navigationController pushViewController:userProfileVc animated:YES];
        }
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}


- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    lastRefresh = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:@"com.Engage.userDefaults.activityviewcontroller.lastRefresh"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
  //  [MBProgressHUD hideHUDForView:self.view animated:YES];
    /*
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
       // self.navigationController.tabBarItem.badgeValue = nil;
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
        
        NSUInteger unreadCount = 0;
        for (PFObject *activity in self.objects) {
            if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:@"activityType"] isEqualToString:@"joined"]) {
                unreadCount++;
            }
        }
        
        if (unreadCount > 0) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)unreadCount];
        } else {
            self.navigationController.tabBarItem.badgeValue = nil;
        }
     */
   // }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"ActivityCell";
    
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [cell setActivity:object];;
    
    if ([lastRefresh compare:[object createdAt]] == NSOrderedAscending) {
        [cell setIsNew:YES];
    } else {
        [cell setIsNew:NO];
    }
    
    [cell hideSeparator:(indexPath.row == self.objects.count - 1)];
    
    return cell;
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
 
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
 
    return cell;
}
 */


#pragma mark - ActivityCellDelegate Methods

- (void)cell:(ActivityCell *)cellView didTapActivityButton:(PFObject *)activity {
    // Get image associated with the activity
    PFObject* story = [activity objectForKey:@"Testimony"];
    
    // Push single photo view controller
    AddStoryCommentViewController* storyDetaisVC = [[AddStoryCommentViewController alloc] initWithStory:story];
    [self.navigationController pushViewController:storyDetaisVC animated:YES];
}

// when user presses user button move to that profile detail view
/*
- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)user {
    // Push account view controller
    * accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    NSLog(@"Presenting account view controller with user: %@", user);
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}
 */

#pragma mark - ActivityViewController
+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:@"like"]) {
        return NSLocalizedString(@"liked your story", nil);
    } else if ([activityType isEqualToString:@"follow"]) {
        return NSLocalizedString(@"started following you", nil);
    } else if ([activityType isEqualToString:@"comment"]) {
        return NSLocalizedString(@"commented on your story", nil);
    } else if ([activityType isEqualToString:@"joined"]) {
        return NSLocalizedString(@"joined Anypic", nil);
    } else {
        return nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
