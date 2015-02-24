//
//  LocalFeedViewController.m
//  Engage
//
//  Created by Angela Smith on 1/22/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "LogInViewController.h"
#import "Utility.h"
#import "Cache.h"
#import "AddStoryCommentViewController.h"
#import "LocalFeedViewController.h"

@interface LocalFeedViewController ()

@end

@implementation LocalFeedViewController

@synthesize actionButton;

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

    // Find who the user follows
    PFQuery* followingActivitiesQuery = [PFQuery queryWithClassName:@"Activity"];
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
    
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0) { // || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return query;
}


- (void)viewDidLoad
{
    // Add background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBg"]];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
            [cell.storyTextLabel sizeToFit];
            [cell setTextStory:object];
            [cell layoutSubviews];
            [cell updateConstraints];
            [cell.likeButton setTag:indexPath.row];
            cell.commentButton.tag = indexPath.row;
            [cell setTag:indexPath.row];
            cell.delegate = self;
            [cell.commentButton addTarget:self action:@selector(didTapCommentButton:) forControlEvents:UIControlEventTouchUpInside];
            
            // Set button attributes
            if (indexPath.row == self.objects.count) {
                // Load More section
                return nil;
            }
            
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
                                           }
                }
            }
            
        }
        return cell;
    }
    else
    {
        // CREATE CELL WITH MEDIA
        StoryMediaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storyCellWithMedia"];
        if (cell != nil)
        {
            cell.playButton.hidden = YES;
            if ([mediaType isEqualToString:@"video"])
            {
                cell.playButton.hidden = NO;
                cell.playButton.tag = indexPath.row;
            }
    //        [cell.storyTextLabel sizeToFit];
            [cell setMediaStory:object];
            [cell layoutSubviews];
            [cell updateConstraints];
            [cell.likeButton setTag:indexPath.row];
            cell.commentButton.tag = indexPath.row;
            [cell setTag:indexPath.row];
            cell.delegate = self;
            [cell.commentButton addTarget:self action:@selector(didTapCommentButton:) forControlEvents:UIControlEventTouchUpInside];
            
            // Set button attributes
            if (indexPath.row == self.objects.count) {
                // Load More section
                return nil;
            }
            
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


#pragma mark - BUTTON ACTION METHODS
-(IBAction)menuButtonPressed:(UIButton*)button
{
    /*
     // Open the menu
     if (button.tag == 0)
     {
     
     UIViewController *viewController = [[UIViewController alloc] init];
     viewController.title = @"Pushed Controller";
     viewController.view.backgroundColor = [UIColor whiteColor];
     [self.navigationController pushViewController:viewController animated:YES];
     }
     // Open the action sheet
     else if (button.tag == 1)
     { */
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Post a Story", @"Find Friends", nil];
    //actionSheet.tag = 0;
    //  [actionSheet showFromBarButtonItem:actionButton animated:true];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    //}
}

- (void)storyActionFooter:(StoryMediaCell*)storyActionFooter didTapLikeMediaStoryButton:(UIButton*)button story:(PFObject *)story
{
    // Like or dislike the media story
    NSLog(@"User liked the media story, passing properties to like or unlike");
    [self likeOrInlikeStory:button story:story cellFooter:storyActionFooter];
}

-(void)likeOrInlikeStory:(UIButton*)button story:(PFObject *)story cellFooter:(StoryMediaCell*) cellFooter {
    NSLog(@"liking or unliking");
    
    PFObject* thisStory = [self.objects objectAtIndex:button.tag];
    // Disable the button so users cannot send duplicate requests
    [cellFooter shouldEnableLikeButton:NO];
    
    
    BOOL liked = !button.selected;
    [cellFooter setLikeStatus:liked];
    NSString* originalButtonTitle = button.titleLabel.text;
    NSNumber* likeCount;
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if (([originalButtonTitle isEqualToString:@""]) || ([originalButtonTitle isEqualToString:@"  Like"]))
    {
        // we had 0 likes
        likeCount = 0;
    }
    else
    {
        NSString* stringSuffix = [originalButtonTitle substringFromIndex: [originalButtonTitle length] - 1];
        // Get rid of the Like or Likes
        NSString* numberString = ([stringSuffix isEqualToString:@"s"]) ? [originalButtonTitle substringToIndex:[originalButtonTitle length]-6] : [originalButtonTitle substringToIndex: [originalButtonTitle length] - 5];
        // Get rid of the spaces
        
        NSString* toNumberString = [numberString substringFromIndex:2];
        // Get the number of likes and comments
        likeCount = [numberFormatter numberFromString:toNumberString];
    }
    if (liked) {
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[Cache sharedCache] incrementLikerCountForPhoto:thisStory];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[Cache sharedCache] decrementLikerCountForPhoto:thisStory];
    }
    
    [[Cache sharedCache] setPhotoIsLikedByCurrentUser:thisStory liked:liked];
    NSString* likeLabel = [self getButtonTitle:[NSString stringWithFormat:@"%@", likeCount] isLike:TRUE];
    [button setTitle:likeLabel forState:UIControlStateNormal];
    [button setTitle:likeLabel forState:UIControlStateSelected];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    UIButton* thisButton = (UIButton *)button;
    StoryTextCell* cell = (StoryTextCell *)thisButton.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (liked) {
        [Utility likeStoryInBackground:thisStory block:^(BOOL succeeded, NSError *error)
         {
             StoryTextCell* textCell = (StoryTextCell *)[self tableView:self.tableView  cellForRowAtIndexPath:indexPath];
             [textCell shouldEnableLikeButton:YES];
             [textCell setLikeStatus:succeeded];
             
             if (!succeeded) {
                 // replace with the origional title
                 [textCell.likeButton setTitle:originalButtonTitle  forState:UIControlStateNormal];
                 textCell.likeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                 //[textCell.likeButton sizeToFit];
             }
         }];
    } else {
        [Utility unlikeStoryInBackground:thisStory block:^(BOOL succeeded, NSError *error)
         {
             StoryTextCell* textCell = (StoryTextCell *)[self.tableView cellForRowAtIndexPath:indexPath];
             [textCell shouldEnableLikeButton:YES];
             [textCell setLikeStatus:!succeeded];
             
             if (!succeeded) {
                 // replace the origional title
                 [textCell.likeButton setTitle:originalButtonTitle  forState:UIControlStateNormal];
                 textCell.likeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                 //[textCell.likeButton sizeToFit];
             }
         }];
    }
}

- (void)storyActionFooter:(StoryTextCell*)storyActionFooter didTapTextLikeStoryButton:(UIButton*)button story:(PFObject *)story
{
    
    PFObject* thisStory = [self.objects objectAtIndex:button.tag];
    // Disable the button so users cannot send duplicate requests
    [storyActionFooter shouldEnableLikeButton:NO];
    
    
    BOOL liked = !button.selected;
    [storyActionFooter setLikeStatus:liked];
    NSString* originalButtonTitle = button.titleLabel.text;
    NSNumber* likeCount;
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if (([originalButtonTitle isEqualToString:@""]) || ([originalButtonTitle isEqualToString:@"  Like"]))
    {
        // we had 0 likes
        likeCount = 0;
    }
    else
    {
        NSString* stringSuffix = [originalButtonTitle substringFromIndex: [originalButtonTitle length] - 1];
        // Get rid of the Like or Likes
        NSString* numberString = ([stringSuffix isEqualToString:@"s"]) ? [originalButtonTitle substringToIndex:[originalButtonTitle length]-6] : [originalButtonTitle substringToIndex: [originalButtonTitle length] - 5];
        // Get rid of the spaces
        
        NSString* toNumberString = [numberString substringFromIndex:2];
        // Get the number of likes and comments
        likeCount = [numberFormatter numberFromString:toNumberString];
    }
    if (liked) {
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[Cache sharedCache] incrementLikerCountForPhoto:thisStory];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[Cache sharedCache] decrementLikerCountForPhoto:thisStory];
    }
    
    [[Cache sharedCache] setPhotoIsLikedByCurrentUser:thisStory liked:liked];
    NSString* likeLabel = [self getButtonTitle:[NSString stringWithFormat:@"%@", likeCount] isLike:TRUE];
    [button setTitle:likeLabel forState:UIControlStateNormal];
    [button setTitle:likeLabel forState:UIControlStateSelected];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    UIButton* thisButton = (UIButton *)button;
    StoryTextCell* cell = (StoryTextCell *)thisButton.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (liked) {
        [Utility likeStoryInBackground:thisStory block:^(BOOL succeeded, NSError *error)
         {
             StoryTextCell* textCell = (StoryTextCell *)[self tableView:self.tableView  cellForRowAtIndexPath:indexPath];
             [textCell shouldEnableLikeButton:YES];
             [textCell setLikeStatus:succeeded];
             
             if (!succeeded) {
                 // replace with the origional title
                 [textCell.likeButton setTitle:originalButtonTitle  forState:UIControlStateNormal];
                 textCell.likeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                 //[textCell.likeButton sizeToFit];
             }
         }];
    } else {
        [Utility unlikeStoryInBackground:thisStory block:^(BOOL succeeded, NSError *error)
         {
             StoryTextCell* textCell = (StoryTextCell *)[self.tableView cellForRowAtIndexPath:indexPath];
             [textCell shouldEnableLikeButton:YES];
             [textCell setLikeStatus:!succeeded];
             
             if (!succeeded) {
                 // replace the origional title
                 [textCell.likeButton setTitle:originalButtonTitle  forState:UIControlStateNormal];
                 textCell.likeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                 //[textCell.likeButton sizeToFit];
             }
         }];
    }
}


- (IBAction)didTapCommentButton:(id)sender
{
    // User is segued to detail view
    //NSLog(@"User tapped Comment Button");
}

#pragma mark - Segue Methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton*)sender
{
    if ([segue.identifier isEqualToString:@"segueToComment"])
    {
        PFObject* story = [self.objects objectAtIndex:sender.tag];
        AddStoryCommentViewController* addCommentVC = segue.destinationViewController;
        addCommentVC.thisStory = story;
    }
    else if ([segue.identifier isEqualToString:@"textSegueToComment"])
    {
        PFObject* story = [self.objects objectAtIndex:sender.tag];
        AddStoryCommentViewController* addCommentVC = segue.destinationViewController;
        addCommentVC.thisStory = story;
    }
    
    
}
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // This is the add story tag
    if (buttonIndex == 0)
    {
        
        UIViewController *controller =  [self.storyboard instantiateViewControllerWithIdentifier:@"addStoryVC"];
        [self.navigationController pushViewController:controller animated:YES];
    }
    // Find Friends
    else if (buttonIndex == 1)
    {
        NSLog(@"User wants to find friends");
        UIViewController *controller =  [self.storyboard instantiateViewControllerWithIdentifier:@"findFriendsTable"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
