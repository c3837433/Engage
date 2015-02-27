//
//  PostTableViewController.m
//  EngageCells
//
//  Created by Angela Smith on 2/15/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//
#import "FindStoriesViewController.h"
#import "FindFriendTableViewController.h"
#import "PostTableViewController.h"
#import "UserDetailsViewController.h"
#import "AddStoryViewController.h"
#import "TextCommentDetailViewController.h"
#import "MediaCommentDetailViewController.h"
#import "Utility.h"
#import "PostImageCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Cache.h"
#import "HashTagViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "CustomAlertView.h"
#import "MZCustomTransition.h"
#import "LeftPanelViewController.h"

@implementation PostTableViewController

@synthesize actionButton, segmentedControl, controlItems;

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
    [[DZNSegmentedControl appearance] setBackgroundColor:[UIColor whiteColor]];
    [[DZNSegmentedControl appearance] setTintColor:[UIColor darkGrayColor]];
    [[DZNSegmentedControl appearance] setHairlineColor:[UIColor darkGrayColor]];
    
    [[DZNSegmentedControl appearance] setFont:[UIFont fontWithName:aFont size:15.0]];
    [[DZNSegmentedControl appearance] setSelectionIndicatorHeight:2.5];
    [[DZNSegmentedControl appearance] setAnimationDuration:0.125];
    [[DZNSegmentedControl appearance] setHeight:55.0f];
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
            //[query includeKey:@"Comment"];
           // [query includeKey:@"Likes"];
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
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return query;
}

#pragma mark - VIEW CONTROLLER METHODS

- (void)viewDidLoad
{
    controlItems = @[@"Global Stories", @"Local Stories"];
    searchBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(menuButtonPressed:)];
    // create the two buttons
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.addBtn, searchBtn, nil];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Add background image
    UIImage* backgroundImage = [UIImage imageNamed:@"MainBg"];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [backgroundImage drawInRect:self.view.bounds];
    UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:newimage];
    
    self.tableView.estimatedRowHeight = 180;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // set up the custom search view
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    
    [MZFormSheetController registerTransitionClass:[MZCustomTransition class] forTransitionStyle:MZFormSheetTransitionStyleCustom];
}

-(void) openNewPostView {
    NSLog(@"We need to display add view");
    
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"customAddPost"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    CustomAddPostViewController* customControl = (CustomAddPostViewController*) vc.topViewController;
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
    NSLog(@"Returned from post with saved %d", saved);
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

#pragma mark - UITABLEVIEW DELEGATE AND DATA SOURCE METHODS
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
        // Create a testing cell InSetPostTextCell  PostTextCell InSetPostTextButtonsCell
        PostTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InSetPostTextButtonsCell"];
        if (cell != nil) {
            // Set the saying to the cell
            PFObject* saying = self.objects[indexPath.row];
            // Set up buttons
            [cell.likeButton setTag:indexPath.row];
            cell.commentButton.tag = indexPath.row;
            [cell setTag:indexPath.row];
            cell.delegate = self;
            
            // the cell attributes
           [self setAttributesForStory:saying inCell:cell atIndexPath:indexPath];
            [cell setUpStory:saying];
            // set up hashtags
            [cell.postStoryLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
                
               NSString* selectedHotWord = [NSString stringWithFormat:@"%@", hotWords[hotWord]];
                if ([selectedHotWord isEqual:@"Hashtag"]) {
                    NSString *word = [string substringFromIndex:1];

                    HashTagViewController* hashTagVC = [self.storyboard instantiateViewControllerWithIdentifier:@"hashtagVC"];
                    hashTagVC.seletedHashtag = word;
                    [self.navigationController pushViewController:hashTagVC animated:YES];
                }
            }];
        }
        return cell;
    } else {
        // set the image cell  InSetPostMediaCell PostImageCell
        PostImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InSetPostMediaCell"];
        if (cell != nil) {
            // Set up buttons
            [cell.likeButton setTag:indexPath.row];
            cell.commentButton.tag = indexPath.row;
            cell.playButton.tag = indexPath.row;
            [cell setTag:indexPath.row];
            cell.delegate = self;
            // the cell attributes
            [self setAttributesForStory:saying inCell:cell atIndexPath:indexPath];
             [cell setUpStory:saying];
            // and the image
            [cell setPostImageFrom:saying];
            // and up hashtags
            [cell.postStoryLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
                NSString* selectedHotWord = [NSString stringWithFormat:@"%@", hotWords[hotWord]];
                if ([selectedHotWord isEqual:@"Hashtag"]) {
                    NSString *word = [string substringFromIndex:1];
                    HashTagViewController *hashTagVC = [[HashTagViewController alloc] init];
                    hashTagVC.seletedHashtag = word;
                    [self.navigationController pushViewController:hashTagVC animated:YES];
                }
                
            }];
        }
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    // Get and return the load more cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}


#pragma mark - Segue Methods //textCommentSegue  postImageSegueToComment
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton*)sender
{
    if ([segue.identifier isEqualToString:@"textCommentSegue"])
    {
        PFObject* story = [self.objects objectAtIndex:sender.tag];
        TextCommentDetailViewController *textVC = segue.destinationViewController;
        textVC.thisStory = story;
    }
    else if ([segue.identifier isEqualToString:@"postImageSegueToComment"])
    {
        PFObject* story = [self.objects objectAtIndex:sender.tag];
        MediaCommentDetailViewController* mediaVC = segue.destinationViewController;
        mediaVC.thisStory = story;
    }
}


- (IBAction)didTapCommentButton:(id)sender
{
    // User is segued to detail view, method passes to prepare for segue
}


#pragma mark - HOTWORDS LABEL SELECTION

-(void)alertUserWithSelection:(NSString*)type word:(NSString*)word {
    NSString* alertTitle = [NSString stringWithFormat:@"You Tapped the %@", type];
    [[[UIAlertView alloc] initWithTitle:alertTitle message:word delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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

#pragma mark - STORY ATTRIBUTES
-(void)setAttributesForStory:(PFObject*)story inCell:(PostTextCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    
    NSDictionary* attributesForPhoto = [[Cache sharedCache] attributesForPhoto:story];
    if (attributesForPhoto) {
        
        [cell setLikeStatus:[[Cache sharedCache] isPhotoLikedByCurrentUser:story]];
        if (cell.likeButton.alpha < 1.0f || cell.commentButton.alpha < 1.0f) {
            [UIView animateWithDuration:0.200f animations:^{
                cell.likeButton.alpha = 1.0f;
                cell.commentButton.alpha = 1.0f;
            }];
        }
    } else {
        cell.likeButton.alpha = 0.0f;
        cell.commentButton.alpha = 0.0f;
        
        @synchronized(self) {
            // check if we can update the cache
            NSNumber* queryStatus = [self.activityQueries objectForKey:@(indexPath.row)];
            if (!queryStatus) {
                PFQuery* query = [Utility queryForLikersForStory:story cachePolicy:kPFCachePolicyNetworkOnly];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self) {
                        [self.activityQueries removeObjectForKey:@(indexPath.row)];
                        if (error) {
                            return;
                        }
                       // NSMutableArray *commenters = [NSMutableArray array];
                        BOOL isLikedByCurrentUser = NO;
                         NSMutableArray *likers = [NSMutableArray array];
                        for (PFObject* liker in objects) {
                            if ([[[liker objectForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                isLikedByCurrentUser = YES;
                            }
                            // add the story liker to the list of likers
                            [likers addObject:[liker objectForKey:@"fromUser"]];
                        }
                        [[Cache sharedCache] setLikeAttributesForStory:story likers:likers likedByCurrentUser:isLikedByCurrentUser];

                        if (cell.tag != indexPath.row) {
                            return;
                        }
                        // SET LIKES
                        [cell setLikeStatus:[[Cache sharedCache] isPhotoLikedByCurrentUser:story]];
                        if (cell.likeButton.alpha < 1.0f || cell.commentButton.alpha < 1.0f) {
                            [UIView animateWithDuration:0.200f animations:^{
                                cell.likeButton.alpha = 1.0f;
                                cell.commentButton.alpha = 1.0f;
                            }];
                        }
                    }

                }];
            }
        }
    }

}

- (NSString *)extractString:(NSString *)fullString toLookFor:(NSString *)lookFor skipForwardX:(NSInteger)skipForward toStopBefore:(NSString *)stopBefore {
    NSRange firstRange = [fullString rangeOfString:lookFor];
    NSRange secondRange = [[fullString substringFromIndex:firstRange.location + skipForward] rangeOfString:stopBefore];
    NSRange finalRange = NSMakeRange(firstRange.location + skipForward, secondRange.location);
    
    return [fullString substringWithRange:finalRange];
}

- (void)postTextCell:(PostTextCell *)postTextCell didTapUserButton:(UIButton *)button user:(PFUser *)user {
    NSLog(@"User tapped user image or user name: %@", user);
    UserDetailsViewController* userDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"userDetailsVc"];
    userDetailsVC.fromPanel = false;
    userDetailsVC.thisUser = user;
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}


- (void)postTextCell:(PostTextCell *)postTextCell didTapOptionsButton:(UIButton *)button story:(PFObject *)story {
    NSLog(@"User tapped options button image on story: %@", story);
    // see if the current user is the author
    if ([story objectForKey:@"author"] == [PFUser currentUser]) {
        // display delete/edit button
        CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:nil message:@"Would you like to edit your testimony" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View and Edit", @"Delete", nil];
        // pass this story to it
        alertView.selectedStory = story;
        alertView.tag = 0;
        [alertView show];
    } else {
        // display flag button
        CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Flag Story for Review" message:@"What is the issue with this story?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Innapropriate", @"Don't Like it", nil];
        // pass this story to it
        alertView.selectedStory = story;
        alertView.tag = 1;
        [alertView show];
        
    }
}

- (void) postTextCell:(PostTextCell *)postTextCell didTapLikeTextStoryButton:(UIButton *)button story:(PFObject *)story {
    
   // NSLog(@"User tapped like story: %@", story);
    // see if the user selected the story
        BOOL liked = !button.selected;
    // stop user from clicking the button again
    [postTextCell shouldEnableLikeButton:NO];
    //PostTextCell* cell = (PostTextCell *)button.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:postTextCell];
    // get the likes for this story
    int likeCount = 0;
    int comentCount = 0;
    // see how many likes or comments this story has
    if ([story objectForKey:@"Likes"]) {
        // get the likes
        likeCount = [[story objectForKey:@"Likes"] intValue];
        if (liked) {
            // increase count
            if (likeCount == 0) {
                likeCount = 1;
            } else {
                likeCount = likeCount + 1;
            }
        } else {
            // decrease count
            if (likeCount < 1) {
                likeCount = 0;
            } else {
                likeCount = likeCount - 1;
            }
        }
    }
    // see how many likes or comments this story has
    if ([story objectForKey:@"Comments"]) {
        // get the comment count
        comentCount = [[story objectForKey:@"Comments"] intValue];
    }
    
    NSString* activityButtonString = @"";
    if ((likeCount != 0) || (comentCount != 0)) {
        // get the button string
        activityButtonString = [self getButtonTitleForLikes:likeCount andComments:comentCount];
        // set the string to the button
        [postTextCell.likesCommentsButton setTitle:activityButtonString forState:UIControlStateNormal];
        [postTextCell.likesCommentsButton setTitle:activityButtonString forState:UIControlStateHighlighted];
    }
    
    [postTextCell setLikeStatus:liked];
    [[Cache sharedCache] setPhotoIsLikedByCurrentUser:story liked:liked];
    
    if (liked) {
        NSLog(@"Liking text story");
        [Utility likeStoryInBackground:story block:^(BOOL succeeded, NSError *error) {
            // get this cell
            PostTextCell* postCell = (PostTextCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
            [postCell shouldEnableLikeButton:YES];
            [postCell setLikeStatus:succeeded];
        }];
    } else {
        NSLog(@"Unliking text story");
        [Utility unlikeStoryInBackground:story block:^(BOOL succeeded, NSError *error) {
            PostTextCell* postCell = (PostTextCell *)[self tableView:self.tableView  cellForRowAtIndexPath:indexPath];
            [postCell shouldEnableLikeButton:YES];
            [postCell setLikeStatus:succeeded];
        }];
    }
   
}


- (void)postTextCell:(PostTextCell *)postTextCell didTapHomeGroupButton:(UIButton *)button group:(PFObject *)group {
    NSLog(@"User tapped home group: %@", group);
  //  PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo];
    //[self.navigationController pushViewController:photoDetailsVC animated:YES];
}

-(NSString*)getButtonTitleForLikes:(int)likes andComments:(int)comments
{
    NSString* likeString = @"";
    // get the likes
    if (likes != 0) {
        likeString = (likes == 1) ? @"1 Like" : [NSString stringWithFormat:@"%d Likes",likes];
    }
    NSString* commentString = @"";
    // get the comments
    if (comments != 0) {
        commentString = (comments == 1) ? @"1 Comment" : [NSString stringWithFormat:@"%d Comments",comments];
    }
    return [NSString stringWithFormat:@"%@ %@", likeString, commentString];
}


// If the user gave permission, change the default and store that value as a PFUser value
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // get the object
    PFObject* saying = ((CustomAlertView *) alertView).selectedStory;
    if (alertView.tag == 0) {
        // this is the edit delete for current user option
        // this is the curent user selecting about editing their story
        if (buttonIndex == 0) {
            NSLog(@"user selected alert tag 0 button index 0");
            // User wants to edit story
           /* AddStoryViewController* addStoryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addStoryVC"];
            addStoryVC.fromPanel = false;
            addStoryVC.thisSaying = saying;*/
            //[self.navigationController pushViewController:addStoryVC animated:YES];
        } else if (buttonIndex == 1) {
            NSLog(@"user selected alert tag 0 button index 1");
            // user wants to delete their story
            /*
            [saying deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // alert deleted
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Testimony Deleted"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                    [self loadObjects];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Unable to Delete" message:@"Sorry, we are unable to delete this testimony at this time."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                }
            }];*/
        } else {
            // user canceled
            saying = nil;
        }
    }
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            NSLog(@"user selected alert tag 1 button index 0"); // cancel
        } else if (buttonIndex == 1) {
            
            NSLog(@"user selected alert tag 1 button index 1"); // innapropriate
        } else {
            NSLog(@"user selected alert tag 1 button index 2"); // don't like it
        }
    }
       
}

-(IBAction)onPlayMovie:(UIButton*)button
{
    // Get the story that triggered the button
    PFObject* thisStory = [self.objects objectAtIndex:button.tag];
    // Get the video file
    PFFile* movieFile = [thisStory objectForKey:@"uploadedMedia"];
    // Get the url for that movie
    NSString* movieUrl = movieFile.url;
    // Initialize the movie player
    MPMoviePlayerViewController* moviePlayerControl = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:movieUrl]];
    moviePlayerControl.moviePlayer.fullscreen=TRUE;
    
    [self presentMoviePlayerViewControllerAnimated:moviePlayerControl];
    [moviePlayerControl.moviePlayer play];
    
}


#pragma mark -  ACTION BAR METHODS
-(IBAction)menuButtonPressed:(UIButton*)button
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Find Friends", @"Find Stories",  nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(IBAction)onAddClick:(UIButton*)button {
    [self openNewPostView];
    //AddStoryViewController* addStoryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addStoryVC"];
   // addStoryVC.fromPanel = false;
   // [self.navigationController pushViewController:addStoryVC animated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"User wants to find friends");
        FindFriendTableViewController *controller =  [self.storyboard instantiateViewControllerWithIdentifier:@"findFriendsTable"];
        controller.needSearchName = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (buttonIndex == 1) {
        NSLog(@"User wants to search for stories");
        FindStoriesViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"findStoriesVC"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
