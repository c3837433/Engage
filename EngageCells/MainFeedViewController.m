//
//  MainFeedViewController.m
//  Engage
//
//  Created by Angela Smith on 8/16/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "MainFeedViewController.h"
#import "Utility.h"
#import "Cache.h"

@interface MainFeedViewController ()

@end

@implementation MainFeedViewController

#pragma mark - Parse Methods
// Storyboard init
-(id)initWithCoder:(NSCoder *)aDecoder
{
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

// Search parse for Stories to be displayed withing the table
- (PFQuery *)queryForTable {
    // If this is not the current user, do not return anythign
    if (![PFUser currentUser])
    {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    // Find all stories on Parse
    PFQuery* query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    // remove any stories that are flagged
    [query whereKeyDoesNotExist:@"Flagged"];
    return query;
    /*
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0) { // || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }*/
   // return query;
}


- (void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Add background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBg"]];
}

// Reload the table when returning from comment view
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITABLEVIEW DELEGATE
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    // Check the story type
    NSString* mediaType = [object objectForKey:@"media"];
    
    // If there are more objects than are displayed, add the load more cell
    if (indexPath.row == self.objects.count)
    {
        UITableViewCell* loadMoreCell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return loadMoreCell;
    }
    else if ([mediaType isEqualToString:@"text"])
    {
        
        // CREATE CELL WITH TEXT ONLY
        StoryTextCell* cell = [tableView dequeueReusableCellWithIdentifier:@"storyCellWithText"];
        if (cell != nil)
        {
            // Detect when the user selects on one of the handles
            [cell.storyTextLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
                
                NSString* selection = [NSString stringWithFormat:@"%@ [%d,%d]: %@%@", hotWords[hotWord], (int)range.location, (int)range.length, string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
                
                // Log what user selects
                NSLog(@"%@", selection);
                
                
            }];
            
            // SET OTHER CELL VALUES
            [cell setTextStory:object];
            [cell layoutSubviews];
            [cell updateConstraints];
            [cell.likeButton setTag:indexPath.row];
            cell.commentButton.tag = indexPath.row;
            [cell setTag:indexPath.row];
            cell.delegate = self;
            
            //[cell.commentButton addTarget:self action:@selector(didTapCommentButton:) forControlEvents:UIControlEventTouchUpInside];
            
            /*
            if (indexPath.row == self.objects.count) {
                // Load More section
                return nil;
            }
             */
             // Set button attributes
            PFObject* story = [self.objects objectAtIndex:indexPath.row];
            NSDictionary* attributesForPhoto = [[Cache sharedCache] attributesForPhoto:story];
            
            if (attributesForPhoto) {
                [cell setLikeStatus:[[Cache sharedCache] isPhotoLikedByCurrentUser:story]];
                
                NSString* titleLabel = [self getButtonTitle:[[[Cache sharedCache] likeCountForPhoto:story] description] isLike:TRUE];
                
                [cell.likeButton setTitle:titleLabel forState:UIControlStateNormal];
                [cell.likeButton setTitle:titleLabel forState:UIControlStateSelected];
                cell.likeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                //[cell.likeButton sizeToFit];
                
                NSString* commentTitle = [self getButtonTitle:[[[Cache sharedCache] commentCountForPhoto:story] description] isLike:FALSE];
                [cell.commentButton setTitle:commentTitle forState:UIControlStateNormal];
                [cell.commentButton setTitle:commentTitle forState:UIControlStateSelected];
                cell.commentButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                //[cell.commentButton sizeToFit];
                
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
                        PFQuery *query = [Utility queryForActivitiesOnStory:story cachePolicy:kPFCachePolicyNetworkOnly];
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            @synchronized(self) {
                                [self.activityQueries removeObjectForKey:@(indexPath.row)];
                                
                                if (error) {
                                    return;
                                }
                                
                                NSMutableArray *likers = [NSMutableArray array];
                                NSMutableArray *commenters = [NSMutableArray array];
                                
                                BOOL isLikedByCurrentUser = NO;
                                
                                for (PFObject *activity in objects) {
                                    if ([[activity objectForKey:@"activityType"] isEqualToString:@"like"] && [activity objectForKey:@"fromUser"]) {
                                        [likers addObject:[activity objectForKey:@"fromUser"]];
                                    } else if ([[activity objectForKey:@"activityType"] isEqualToString:@"comment"] && [activity objectForKey:@"fromUser"]) {
                                        [commenters addObject:[activity objectForKey:@"fromUser"]];
                                    }
                                    
                                    if ([[[activity objectForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                        if ([[activity objectForKey:@"activityType"] isEqualToString:@"like"]) {
                                            isLikedByCurrentUser = YES;
                                        }
                                    }
                                }
                                
                                [[Cache sharedCache] setAttributesForPhoto:story likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                                
                                if (cell.tag != indexPath.row) {
                                    return;
                                }
                                // SET LIKES
                                [cell setLikeStatus:[[Cache sharedCache] isPhotoLikedByCurrentUser:story]];
                                
                                NSString* titleString = [self getButtonTitle:[[[Cache sharedCache] likeCountForPhoto:story] description] isLike:YES];
                                
                                [cell.likeButton setTitle:titleString forState:UIControlStateNormal];
                                [cell.likeButton setTitle:titleString forState:UIControlStateSelected];
                                cell.likeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                                
                                NSString* commentTitle = [self getButtonTitle:[[[Cache sharedCache] commentCountForPhoto:story] description] isLike:FALSE];
                                [cell.commentButton setTitle:commentTitle forState:UIControlStateNormal];
                                [cell.commentButton setTitle:commentTitle forState:UIControlStateSelected];
                                cell.commentButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                                
                                
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
        return cell;
    }
    else
    {
        // CREATE CELL WITH MEDIA
        StoryMediaCell* cell = [tableView dequeueReusableCellWithIdentifier:@"storyCellWithMedia"];
        if (cell != nil)
        {

          //  cell.playButton.hidden = YES;
            if ([mediaType isEqualToString:@"video"])
            {
            //    cell.playButton.hidden = NO;
              //  cell.playButton.tag = indexPath.row;
            }
            // Detect when the user selects on one of the handles
            [cell.storyTextLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
                
                NSString* selection = [NSString stringWithFormat:@"%@ [%d,%d]: %@%@", hotWords[hotWord], (int)range.location, (int)range.length, string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
                
                // Log what user selects
                NSLog(@"%@", selection);
                
                
            }];
            
            //[cell.storyTextLabel sizeToFit];
            [cell setMediaStory:object];
            [cell layoutSubviews];
            [cell updateConstraints];
            [cell.likeButton setTag:indexPath.row];
            cell.commentButton.tag = indexPath.row;
            [cell setTag:indexPath.row];
            cell.delegate = self;
           // [cell.commentButton addTarget:self action:@selector(didTapCommentButton:) forControlEvents:UIControlEventTouchUpInside];
            /*
            // Set button attributes
            if (indexPath.row == self.objects.count) {
                // Load More section
                return nil;
            }
            */
            PFObject* story = [self.objects objectAtIndex:indexPath.row];
            NSDictionary* attributesForPhoto = [[Cache sharedCache] attributesForPhoto:story];
            
            if (attributesForPhoto) {
                [cell setLikeStatus:[[Cache sharedCache] isPhotoLikedByCurrentUser:story]];
                
                NSString* titleLabel = [self getButtonTitle:[[[Cache sharedCache] likeCountForPhoto:story] description] isLike:TRUE];
                
                [cell.likeButton setTitle:titleLabel forState:UIControlStateNormal];
                [cell.likeButton setTitle:titleLabel forState:UIControlStateSelected];
                cell.likeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                //[cell.likeButton sizeToFit];
                
                NSString* commentTitle = [self getButtonTitle:[[[Cache sharedCache] commentCountForPhoto:story] description] isLike:FALSE];
                [cell.commentButton setTitle:commentTitle forState:UIControlStateNormal];
                [cell.commentButton setTitle:commentTitle forState:UIControlStateSelected];
                cell.commentButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                //[cell.commentButton sizeToFit];
                
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
                        PFQuery *query = [Utility queryForActivitiesOnStory:story cachePolicy:kPFCachePolicyNetworkOnly];
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            @synchronized(self) {
                                [self.activityQueries removeObjectForKey:@(indexPath.row)];
                                
                                if (error) {
                                    return;
                                }
                                
                                NSMutableArray *likers = [NSMutableArray array];
                                NSMutableArray *commenters = [NSMutableArray array];
                                
                                BOOL isLikedByCurrentUser = NO;
                                
                                for (PFObject *activity in objects) {
                                    if ([[activity objectForKey:@"activityType"] isEqualToString:@"like"] && [activity objectForKey:@"fromUser"]) {
                                        [likers addObject:[activity objectForKey:@"fromUser"]];
                                    } else if ([[activity objectForKey:@"activityType"] isEqualToString:@"comment"] && [activity objectForKey:@"fromUser"]) {
                                        [commenters addObject:[activity objectForKey:@"fromUser"]];
                                    }
                                    
                                    if ([[[activity objectForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                        if ([[activity objectForKey:@"activityType"] isEqualToString:@"like"]) {
                                            isLikedByCurrentUser = YES;
                                        }
                                    }
                                }
                                
                                [[Cache sharedCache] setAttributesForPhoto:story likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                                
                                if (cell.tag != indexPath.row) {
                                    return;
                                }
                                // SET LIKES
                                [cell setLikeStatus:[[Cache sharedCache] isPhotoLikedByCurrentUser:story]];
                                NSString* titleString = [self getButtonTitle:[[[Cache sharedCache] likeCountForPhoto:story] description] isLike:YES];
                                
                                [cell.likeButton setTitle:titleString forState:UIControlStateNormal];
                                [cell.likeButton setTitle:titleString forState:UIControlStateSelected];
                                cell.likeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                                
                                NSString* commentTitle = [self getButtonTitle:[[[Cache sharedCache] commentCountForPhoto:story] description] isLike:FALSE];
                                [cell.commentButton setTitle:commentTitle forState:UIControlStateNormal];
                                [cell.commentButton setTitle:commentTitle forState:UIControlStateSelected];
                                cell.commentButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                                
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
        return cell;
    }
    
}

-(NSString*)getButtonTitle:(NSString*)numberString isLike:(BOOL)isLike
{
    //NSString* newString = ([likeString isEqualToString:@"1"]) ? [NSString stringWithFormat:@"  %@ Like", likeString] : [NSString stringWithFormat:@"  %@ Likes", likeString];
    NSString* labelString;
    //NSNumber* likeNumber = [[Cache sharedCache] likeCountForPhoto:story];
    if (([numberString isEqualToString: @"0"]) || ([numberString isEqualToString: @""]))
    {
        labelString = (isLike) ? @"  Like" : @"  Comment";
    }
    else if ([numberString intValue] == 1)
    {
        labelString = (isLike) ? @"  1 Like" : @"  1 Comment";
    }
    else
    {
        labelString = (isLike) ? [NSString stringWithFormat:@"  %@ Likes", numberString] : [NSString stringWithFormat:@"  %@ Comments", numberString];
    }
    return labelString;
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // Reload the table
    [self.tableView reloadData];
}
// Specify the load more cell for when there are additional cells that can be viewed
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    // Get and return the load more cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}



@end
