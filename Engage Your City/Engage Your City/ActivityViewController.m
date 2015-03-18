//
//  ActivityViewController.m
//  Engage
//
//  Created by Angela Smith on 1/22/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "ActivityViewController.h"
#import "ApplicationKeys.h"
#import "Utility.h"
#import "TextCommentDetailViewController.h"
#import "MediaCommentDetailViewController.h"
#import "UserDetailsViewController.h"

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
    PFQuery *query = [PFQuery queryWithClassName:aActivityClass];
    // find all activity that is directed to the user
    [query whereKey:aActivityToUser equalTo:[PFUser currentUser]];
    // find all the activity that was not created by the user
    [query whereKey:aActivityFromUser notEqualTo:[PFUser currentUser]];
    [query whereKey:aActivityType notEqualTo:@"joined"];
    // where the user is connected
    [query whereKeyExists:aActivityFromUser];
    // include the poster
    [query includeKey:aActivityFromUser];
    [query includeKey:aActivityToUser];
    // and story object
    [query includeKey:aActivityStory];
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
    
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [super viewDidLoad];

    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];

    lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.Engage.userDefaults.activityviewcontroller.lastRefresh"];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  //  self.tableView.separatorColor = [UIColor colorWithRed:30.0f/255.0f green:30.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
   [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
        [self.tableView reloadData];
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
  //  [self.navigationController.navigationBar
    // setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    //self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - UITableViewDelegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // Get the saying for this cell
    // see if there is an image
    if (indexPath.row == self.objects.count) {
        [self loadNextPage];
    }
    else {
        PFObject* activity = self.objects[indexPath.row];
        NSLog(@"this activity: %@", activity.description);
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if ([[activity objectForKey:@"activityType"] isEqualToString:@"follow"]) {
            NSLog(@"This is a follow activity");
            PFUser* fromUser = [activity objectForKey:aActivityFromUser];
            UserDetailsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"userDetailsVc"];
            vc.thisUser = fromUser;
            vc.fromPanel = false;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            NSLog(@"This is a like or comment activity");
            PFObject* story = [activity objectForKey:aActivityStory];
            //NSLog(@"Passing the selected story = %@", selectedStory);
            if ([[story objectForKey:@"media"] isEqualToString:@"text"]) {
                // open text view
                NSLog(@"Opening the text detail view");
                // NSLog(@"Passing a text story: %@", selectedStory);
                TextCommentDetailViewController* textVC = [self.storyboard instantiateViewControllerWithIdentifier:@"textDetailVC"];
                textVC.thisStory = nil;
                textVC.thisStory = story;
                [self.navigationController pushViewController:textVC animated:YES];
            } else {
                // open media view
                //NSLog(@"Passing a media story");
                 NSLog(@"Opening the media detail view");
                MediaCommentDetailViewController* mediaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mediaCommntDetail"];
                mediaVC.thisStory = nil;
                mediaVC.thisStory = story;
                [self.navigationController pushViewController:mediaVC animated:YES];
            }
        }
        
    }

    /*
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        PFObject *activity = [self.objects objectAtIndex:indexPath.row];
        // see what type of activity it is
        if ([[activity objectForKey:aActivityType] isEqualToString:aActivityFollow]) {
            // get the from user and display their profile
            PFUser* fromUser = [activity objectForKey:aActivityFromUser];
            UserDetailsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"userDetailsVc"];
            vc.thisUser = fromUser;
            vc.fromPanel = false;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            PFObject* story = [activity objectForKey:aActivityStory];
            // see what type of story
            if ([[story objectForKey:aPostMediaType] isEqualToString:@"text"]) {
                TextCommentDetailViewController* vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"textDetailVC"];
                vc.thisStory = story;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                MediaCommentDetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mediaCommntDetail"];
                vc.thisStory = story;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    } */
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
    if (indexPath.row == self.objects.count)
    {
        UITableViewCell* cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    else {
        PFObject* activity = self.objects[indexPath.row];
        ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
        if (cell != nil) {
            // Set the saying image and time to the cell
        //    PFObject* activity = self.objects[indexPath.row];
            [cell setActivity:activity];
            [cell setTag:indexPath.row];
            /*
            // Set up buttons
            NSDate* timeCreated = activity.createdAt;
            Utility* utility = [[Utility alloc] init];
            NSString* timestamp = [utility stringForTimeIntervalSinceCreated:timeCreated];
            cell.timeLabel.text = timestamp;
            */
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                PFUser* fromUser = [activity objectForKey:aActivityFromUser];
                NSString* fromUserName = [fromUser objectForKey:aUserName];
               // NSLog(@"activity user: %@", fromUserName);
                UIFont* boldFont = [UIFont fontWithName:aFontMed size:14];
                NSMutableDictionary *nameAttributes = [[NSMutableDictionary alloc] init];
                [nameAttributes setObject:boldFont forKey:NSFontAttributeName];
                [nameAttributes setObject:[UIColor darkGrayColor] forKey:NSForegroundColorAttributeName];
                NSAttributedString* nameString = [[NSAttributedString alloc]initWithString:fromUserName attributes:nameAttributes];
                NSString* actionString = @"";
                BOOL needsStory = true;
                NSString* actionType = [activity objectForKey:aActivityType];
             //   NSLog(@"action type returned: %@", actionType);
                if ([actionType isEqualToString:@"like"]) {
                    actionString = @" liked your story ";
                } else if ([actionType isEqualToString:@"comment"]) {
                    actionString = @" commented on your story ";
                } else if ([actionType isEqualToString:@"follow"]) {
                    actionString = @" started following you.";
                    needsStory = false;
                }
               // NSLog(@"story action: %@", actionString);
                //create the action string
                UIFont* normalFont = [UIFont fontWithName:aFont size:14];
                NSMutableDictionary* actionAttributes = [[NSMutableDictionary alloc] init];
                [actionAttributes setObject:normalFont forKey:NSFontAttributeName];
                [actionAttributes setObject:[UIColor darkGrayColor] forKey:NSForegroundColorAttributeName];
                NSAttributedString* actionLabelString = [[NSAttributedString alloc]initWithString:actionString attributes:actionAttributes];
                
                NSString* storyString = @"Empty";
                if (needsStory) {
                    // set up the story name label
                    PFObject* story = [activity objectForKey:aActivityStory];
                    //storyString = [NSString stringWithFormat:@"\"%@\"", [story objectForKey:aPostTitle]];
                    storyString = [story objectForKey:aPostTitle];
                   // NSLog(@"story title: %@", storyString);
                }
                
                UIFont* storyFont = [UIFont fontWithName:aFontMed size:14];
                NSMutableDictionary* storyAttributes = [[NSMutableDictionary alloc] init];
                [storyAttributes setObject:storyFont forKey:NSFontAttributeName];
                [storyAttributes setObject:[UIColor darkGrayColor] forKey:NSForegroundColorAttributeName];
                NSAttributedString* storyLabelString = [[NSAttributedString alloc]initWithString:storyString attributes:storyAttributes];
                
                NSMutableAttributedString * activityLabelString = [[NSMutableAttributedString alloc] init];
                [activityLabelString appendAttributedString:nameString];
                [activityLabelString appendAttributedString:actionLabelString];
                if (needsStory) {
                    [activityLabelString appendAttributedString:storyLabelString];
                }


                
                // update UI on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                      cell.activityLabel.attributedText = activityLabelString;
                });
                
            });
            /*
            // Prepare the from user
            PFUser* fromUser = [activity objectForKey:aActivityFromUser];
            NSString* fromUserName = [fromUser objectForKey:aUserName];
            NSLog(@"activity user: %@", fromUserName);
            UIFont* boldFont = [UIFont fontWithName:aFontMed size:14];
            NSMutableDictionary *nameAttributes = [[NSMutableDictionary alloc] init];
            [nameAttributes setObject:boldFont forKey:NSFontAttributeName];
            [nameAttributes setObject:[UIColor darkGrayColor] forKey:NSForegroundColorAttributeName];
            NSAttributedString* nameString = [[NSAttributedString alloc]initWithString:fromUserName attributes:nameAttributes];
            */
            // SET AUTHOR PICTURE
            //[self.postAuthorPicButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            /*
            // Set name button properties and avatar image
            if ([fromUser objectForKey:aUserImage]) {
                // NSLog(@"The author HAS profile image");
                PFFile* imageFile = [fromUser objectForKey:aUserImage];
                if ([imageFile isDataAvailable]) {
                    //[cell.image loadInBackground];
                    cell.profileImageView.file = imageFile;
                    [cell.profileImageView loadInBackground];
                } else {
                    cell.profileImageView.file = imageFile;
                    [cell.profileImageView loadInBackground];
                }
            } else {
                //  NSLog(@"The author has NO profile image");
                cell.profileImageView.image = [UIImage imageNamed:@"placeholder"];
            }*/

            // Prepare the action
           /* NSString* actionString = @"";
            BOOL needsStory = true;
            NSString* actionType = [activity objectForKey:aActivityType];
            NSLog(@"action type returned: %@", actionType);
            if ([actionType isEqualToString:@"like"]) {
                actionString = @" liked your story ";
            } else if ([actionType isEqualToString:@"comment"]) {
                actionString = @" commented on your story ";
            } else if ([actionType isEqualToString:@"follow"]) {
                actionString = @" started following you.";
                needsStory = false;
            }
            NSLog(@"story action: %@", actionString);
            //create the action string
            UIFont* normalFont = [UIFont fontWithName:aFont size:14];
            NSMutableDictionary* actionAttributes = [[NSMutableDictionary alloc] init];
            [actionAttributes setObject:normalFont forKey:NSFontAttributeName];
            [actionAttributes setObject:[UIColor darkGrayColor] forKey:NSForegroundColorAttributeName];
            NSAttributedString* actionLabelString = [[NSAttributedString alloc]initWithString:actionString attributes:actionAttributes];
            
            NSString* storyString = @"Empty";
            if (needsStory) {
                // set up the story name label
                PFObject* story = [activity objectForKey:aActivityStory];
                //storyString = [NSString stringWithFormat:@"\"%@\"", [story objectForKey:aPostTitle]];
                storyString = [story objectForKey:aPostTitle];
                NSLog(@"story title: %@", storyString);
            }
            
            UIFont* storyFont = [UIFont fontWithName:aFontMed size:14];
            NSMutableDictionary* storyAttributes = [[NSMutableDictionary alloc] init];
            [storyAttributes setObject:storyFont forKey:NSFontAttributeName];
            [storyAttributes setObject:[UIColor darkGrayColor] forKey:NSForegroundColorAttributeName];
            NSAttributedString* storyLabelString = [[NSAttributedString alloc]initWithString:storyString attributes:storyAttributes];
            
            NSMutableAttributedString * activityLabelString = [[NSMutableAttributedString alloc] init];
            [activityLabelString appendAttributedString:nameString];
            [activityLabelString appendAttributedString:actionLabelString];
            if (needsStory) {
                [activityLabelString appendAttributedString:storyLabelString];
            } */
            //NSLog(@"full string: %@", actionLabelString);
            // set the string to the label
          //  cell.activityLabel.attributedText = activityLabelString;
            
        }

        return cell;
    }
}


/*
- (void)longPressLabel:(UILongPressGestureRecognizer *)recognizer
{
    // Only accept gestures on our label and only in the begin state
    if ((recognizer.view != self.label) || (recognizer.state != UIGestureRecognizerStateBegan))
    {
        return;
    }
    
    // Get the position of the touch in the label
    CGPoint location = [recognizer locationInView:self.label];
    
    // Get the link under the location from the label
    MZSelectableLabelRange *selectedRange = [self.label rangeValueAtLocation:location];
    
    if (!selectedRange)
    {
        // No link was touched
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"You long pressed %@", [[self.label.attributedText string] substringWithRange:selectedRange.range]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
    
}
*/
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

/*
#pragma mark - ActivityCellDelegate Methods

- (void)cell:(ActivityCell *)cellView didTapActivityButton:(PFObject *)activity {
    // Get image associated with the activity
    PFObject* story = [activity objectForKey:@"Testimony"];
    
    // Push single photo view controller
    AddStoryCommentViewController* storyDetaisVC = [[AddStoryCommentViewController alloc] initWithStory:story];
    [self.navigationController pushViewController:storyDetaisVC animated:YES];
}
*/
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
