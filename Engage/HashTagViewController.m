//
//  HashTagViewController.m
//  Engage
//
//  Created by Angela Smith on 2/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "HashTagViewController.h"
#import "TextCommentDetailViewController.h"
#import "MediaCommentDetailViewController.h"
#import "Utility.h"
#import "PostImageCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Cache.h"
#import "ApplicationKeys.h"
#import "AppDelegate.h"

@interface HashTagViewController ()

@end

@implementation HashTagViewController
@synthesize seletedHashtag;

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
        self.objectsPerPage = 15;
    }
    return self;
}

// Search parse for Stories to be displayed withing the table
- (PFQuery *)queryForTable {
    // If this is not the current user, do not return anythign
   PFQuery *hashtagQuery = [PFQuery queryWithClassName:@"Hashtags"];
   // [hashtagQuery includeKey:@"Story"];
    [hashtagQuery whereKey:@"tag" equalTo:self.seletedHashtag];
    NSLog(@"The selected hashtag: %@", self.seletedHashtag);
    
    PFQuery* storyQuery = [PFQuery queryWithClassName:@"Testimonies"];
    [storyQuery whereKey:@"objectId" matchesKey:@"PointerString" inQuery:hashtagQuery];
    [storyQuery includeKey:@"author"];
    [storyQuery includeKey:@"Group"];
    [storyQuery orderByDescending:@"createdAt"];
    // remove any stories that are flagged
    [storyQuery whereKeyDoesNotExist:@"Flagged"];
    /*
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [storyQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    } */
    return storyQuery;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"#%@", seletedHashtag];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
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
                    // reload the table with the newly selected word
                    [self reloadTableForNewWord:word];
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
            // set up hashtags
            [cell.postStoryLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
                
                NSString* selectedHotWord = [NSString stringWithFormat:@"%@", hotWords[hotWord]];
                if ([selectedHotWord isEqual:@"Hashtag"]) {
                    NSString *word = [string substringFromIndex:1];
                     [self reloadTableForNewWord:word];
                }
            }];
        }
        return cell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    // Get and return the load more cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}

-(void)reloadTableForNewWord:(NSString*)newWord {
    self.seletedHashtag = newWord;
    // update the title bar
    self.navigationItem.title = [NSString stringWithFormat:@"#%@", seletedHashtag]; 
    [self loadObjects];

}

#pragma mark - Segue Methods //textCommentSegue  postImageSegueToComment
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton*)sender
{
    if ([segue.identifier isEqualToString:@"hashtagSegueToTextComment"])
    {
        PFObject* story = [self.objects objectAtIndex:sender.tag];
        TextCommentDetailViewController *textVC = segue.destinationViewController;
        textVC.thisStory = story;
    }
    else if ([segue.identifier isEqualToString:@"hashtagSegueToMediaComment"])
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (void)postActionButtons:(PostTextCell*)postActionButtons didTapTextLikeStoryButton:(UIButton *)button story:(PFObject *)story;
{
    
    PFObject* thisStory = [self.objects objectAtIndex:button.tag];
    // Disable the button so users cannot send duplicate requests
    [postActionButtons shouldEnableLikeButton:NO];
    
    
    BOOL liked = !button.selected;
    [postActionButtons setLikeStatus:liked];
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
    //  NSString* likeLabel = [self getButtonTitle:[NSString stringWithFormat:@"%@", likeCount] isLike:TRUE];
    //  [button setTitle:likeLabel forState:UIControlStateNormal];
    //   [button setTitle:likeLabel forState:UIControlStateSelected];
    //   button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    UIButton* thisButton = (UIButton *)button;
    PostTextCell* cell = (PostTextCell *)thisButton.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (liked) {
        [Utility likeStoryInBackground:thisStory block:^(BOOL succeeded, NSError *error)
         {
             PostTextCell* textCell = (PostTextCell *)[self tableView:self.tableView  cellForRowAtIndexPath:indexPath];
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
             PostTextCell* textCell = (PostTextCell *)[self.tableView cellForRowAtIndexPath:indexPath];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
