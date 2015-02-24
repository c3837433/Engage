//
//  AddStoryCommentViewController.m
//  Test Engage
//
//  Created by Angela Smith on 8/18/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "AddStoryCommentViewController.h"
//#import "StoryDetailCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "CommentCell.h"
#import "AddCommentFooterCell.h"
#import "StoryDetailsInfoHeaderView.h"
#import "MBProgressHUD.h"
#import "STTweetLabel.h"
#import "ProfileImageView.h"
#import "Utility.h"
#import "Cache.h"


@interface AddStoryCommentViewController ()

@end

@implementation AddStoryCommentViewController
@synthesize headerView, thisStory, commentTextField, likesView, likeStoryButton, storyLikers, currentLikeAvatars;

- (id)initWithStory:(PFObject *)story {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.thisStory = story;
        // The className to query on
        self.parseClassName = @"Comment";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        // The number of comments to show per page
        self.objectsPerPage = 20;
        self.likersQueryInProgress = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get the cell width
    self.cellWidth = self.tableView.frame.size.width;
    
    // BUILD THE STORY HEADER
    // get the height of the View
    NSString* mediaTYpe = [thisStory objectForKey:@"media"];
    NSString* storyText = [thisStory objectForKey:@"story"];
    float textHeight = [self getViewHeight:storyText type:mediaTYpe];
    float stringHeight = [self getStringHeight:storyText];
    self.headerView = [[StoryDetailsInfoHeaderView alloc] initWithFrame:[StoryDetailsInfoHeaderView rectForView:textHeight]];
    
    // ADD USER HEADER NIB
    NSArray* subviewArray = [[NSBundle mainBundle] loadNibNamed:@"StoryDetailHeader" owner:self options:nil];
    DetailStoryHeaderView* userInfoView = [subviewArray objectAtIndex:0];
    if (userInfoView != nil) {
        [userInfoView setDetailHeaderInfo:thisStory];
    }
    [self.headerView addSubview:userInfoView];
    
    
    // ADD TEXT VIEW
    UIView* textUIView = [[UIView alloc] initWithFrame:CGRectMake(8.0f, 0.0f, self.cellWidth - 16, stringHeight)];
    textUIView.backgroundColor = [UIColor whiteColor];
    
    
    //STTweetLabel *textLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(13.0f, 0.0f, 268.0f, stringHeight)];
    STTweetLabel* textLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(8.0f, 0.0f, self.cellWidth - 32, stringHeight)];
    [textLabel setText:storyText];
    textLabel.textAlignment = NSTextAlignmentLeft;
    [textUIView addSubview:textLabel];
    
    // Add view to header
    [self.headerView addSubview:textUIView];
    
    // Update the frames
    CGRect textViewFrame = textUIView.frame;
    textViewFrame.origin.x = 8.0f;
    textViewFrame.origin.y = 88.0f;
    textViewFrame.size.width = self.cellWidth - 16;
    textViewFrame.size.height = stringHeight;
    textUIView.frame = textViewFrame;
    
    CGRect labelFrame = textLabel.frame;
    textViewFrame.origin.x = 16.0f;
    textViewFrame.origin.y = 88.0f;
    textViewFrame.size.width = self.tableView.frame.size.width - 32;
    textViewFrame.size.height = stringHeight;
    textLabel.frame = labelFrame;
    
    // CHECK IF MEDIA IS NEEDED
    NSString* mediaType = [thisStory objectForKey:@"media"];
    BOOL hasMedia = false;
    if (([mediaType isEqualToString:@"photo"]) || ([mediaType isEqualToString:@"video"]))
    {
        hasMedia = true;
        // ADD USER MEDIA NIB
        NSArray* subviewArray2 = [[NSBundle mainBundle] loadNibNamed:@"StoryMediaView" owner:self options:nil];
        DetailStoryMediaView* storyMedia = [subviewArray2 objectAtIndex:0];
        if (storyMedia != nil)
        {
            [storyMedia setDetailStoryMedia:thisStory];
            CGRect mediaViewFrame  = storyMedia.frame;
            mediaViewFrame.origin.x = 0;
            mediaViewFrame.origin.y = 88 + stringHeight;
            storyMedia.frame = mediaViewFrame;
        }
        [self.headerView addSubview:storyMedia];
        
        
    }
    
    // create the likes view
    if (hasMedia) {
        likesView = [[UIView alloc] initWithFrame:CGRectMake(8.0f, textHeight, self.tableView.frame.size.width - 16, 43.0f)];
    } else {
        likesView = [[UIView alloc] initWithFrame:CGRectMake(8.0f, textHeight - 43, self.tableView.frame.size.width - 16, 43.0f)];
    }
    
    [likesView setBackgroundColor:[UIColor whiteColor]];
    [self.headerView addSubview:likesView];
    
    // Create the heart-shaped like button
    likeStoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeStoryButton setFrame:CGRectMake(9.0f, 9.0f, 28.0f, 28.0f)];
    [likeStoryButton setBackgroundColor:[UIColor clearColor]];
    [likeStoryButton setTitleColor:[UIColor colorWithRed:254.0f/255.0f green:149.0f/255.0f blue:50.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [likeStoryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [likeStoryButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [[likeStoryButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [[likeStoryButton titleLabel] setMinimumScaleFactor:0.8f];
    [[likeStoryButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [likeStoryButton setAdjustsImageWhenDisabled:NO];
    [likeStoryButton setAdjustsImageWhenHighlighted:NO];
    [likeStoryButton setBackgroundImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [likeStoryButton setBackgroundImage:[UIImage imageNamed:@"liked"] forState:UIControlStateSelected];
   // [likeStoryButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [likesView addSubview:likeStoryButton];
    [self.headerView addSubview:likesView];
    [self reloadLikeBar];
    
//    UIImageView *separator = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)]];
  //  [separator setFrame:CGRectMake(0.0f, likeBarView.frame.size.height - 1.0f, likeBarView.frame.size.width, 1.0f)];
    //[likeBarView addSubview:separator];
    
    
    [self.headerView layoutSubviews];
    [self.headerView setNeedsDisplay];
    
    self.tableView.tableHeaderView = self.headerView;
    // Do any additional setup after loading the view.
}


- (PFQuery *)queryForTable {
    //NSLog(@"%@", self.thisStory);
    PFQuery *query = [PFQuery queryWithClassName:aActivityClass];
    [query whereKey:aPostClass equalTo:self.thisStory];
    [query includeKey:aActivityFromUser];
    [query whereKey:aActivityType equalTo:aActivityComment];
    [query orderByAscending:@"createdAt"];
    
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    /*   if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
     [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
     }*/
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    [self reloadLikeBar];
    [self loadLikers];
}

- (void)loadLikers {
    if (self.likersQueryInProgress) {
        return;
    }
    
    self.likersQueryInProgress = YES;
    /*
    PFQuery *query = [Utility queryForActivitiesOnStory:thisStory cachePolicy:kPFCachePolicyNetworkOnly];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.likersQueryInProgress = NO;
        if (error) {
           // [self.headerView reloadLikeBar];
            [self reloadLikeBar];
            return;
        }
        
        NSMutableArray *likers = [NSMutableArray array];
        NSMutableArray *commenters = [NSMutableArray array];
        
        BOOL isLikedByCurrentUser = NO;
        
        for (PFObject *activity in objects) {
            if ([[activity objectForKey:aActivityType] isEqualToString:aActivityLike] && [activity objectForKey:aActivityFromUser]) {
                [likers addObject:[activity objectForKey:aActivityFromUser]];
            } else if ([[activity objectForKey:aActivityType] isEqualToString:aActivityComment] && [activity objectForKey:aActivityFromUser]) {
                [commenters addObject:[activity objectForKey:aActivityFromUser]];
            }
            
            if ([[[activity objectForKey:aActivityFromUser] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                if ([[activity objectForKey:aActivityType] isEqualToString:aActivityLike]) {
                    isLikedByCurrentUser = YES;
                }
            }
        }
        
        [[Cache sharedCache] setAttributesForPhoto:thisStory likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
        [self reloadLikeBar];
    }]; */
}

- (void)setLikeUsers:(NSMutableArray *)anArray {
   storyLikers  = [anArray sortedArrayUsingComparator:^NSComparisonResult(PFUser *liker1, PFUser *liker2) {
        NSString *displayName1 = [liker1 objectForKey:@"UsersFullName"];
        NSString *displayName2 = [liker2 objectForKey:@"UsersFullName"];
        
        if ([[liker1 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedAscending;
        } else if ([[liker2 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedDescending;
        }
        
        return [displayName1 compare:displayName2 options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
    }];;
    
    for (ProfileImageView *image in currentLikeAvatars) {
        [image removeFromSuperview];
    }
    
    [likeStoryButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)storyLikers.count] forState:UIControlStateNormal];
    
    currentLikeAvatars = [[NSMutableArray alloc] initWithCapacity:storyLikers.count];
    NSInteger i;
    NSInteger numOfPics = 7.0f > storyLikers.count ? storyLikers.count : 7.0f;
    //NSLog(@"there are %lu@ number of likers", numOfPics);
    for (i = 0; i < numOfPics; i++) {
        PFImageView *profilePic = [[PFImageView alloc] init];
        [profilePic setFrame:CGRectMake(46.0f + i * (3.0f + 30.0f), 6.0f, 30.0f, 30.0f)];
      //  [profilePic.profileButton addTarget:self action:@selector(didTapLikerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //profilePic.profileButton.tag = i;
        profilePic.tag = i;
        
        /*
         if ([thisPostAuthor objectForKey:aPostAuthorImage]) {
         // NSLog(@"The author HAS profile image");
         PFFile* imageFile = [thisPostAuthor objectForKey:aPostAuthorImage];
         if ([imageFile isDataAvailable]) {
         //[cell.image loadInBackground];
         postAuthorImage.file = imageFile;
         [postAuthorImage loadInBackground];
         } else {
         postAuthorImage.file = imageFile;
         [postAuthorImage loadInBackground];
         }
         } else {
         //  NSLog(@"The author has NO profile image");
         postAuthorImage.image = [UIImage imageNamed:@"placeholder"];
         }

         */
        
        if ([Utility userHasProfilePictures:[storyLikers objectAtIndex:i]]) {
            
            [profilePic setFile:[[storyLikers objectAtIndex:i] objectForKey:@"profilePictureSmall"]];
        } else {
            //[profilePic setImage:[Utility defaultProfilePicture]];
            profilePic.image = [UIImage imageNamed:@"placeholder"];
        }
        
        [likesView addSubview:profilePic];
        [currentLikeAvatars addObject:profilePic];
    }
    
  //  [self setNeedsDisplay];
}

- (void)setLikeButtonState:(BOOL)selected {
    if (selected) {
        [likeStoryButton setTitleEdgeInsets:UIEdgeInsetsMake( -1.0f, 0.0f, 0.0f, 0.0f)];
    } else {
        [likeStoryButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
    }
    [likeStoryButton setSelected:selected];
}

- (void)reloadLikeBar {
   // NSLog(@"Loading like bar");
    storyLikers = [[Cache sharedCache] likersForPhoto:thisStory];
    [self setLikeButtonState:[[Cache sharedCache] isPhotoLikedByCurrentUser:thisStory]];
   // [likeStoryButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    if (indexPath.row == self.objects.count)
    {
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    else
    {
        
        CommentCell* cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        if (cell != nil)
        {
            [cell setComment:object];
            cell.commentText.lineBreakMode = NSLineBreakByWordWrapping;
            cell.commentText.numberOfLines = 0;
            cell.commentText.font = [UIFont systemFontOfSize:13.0];
            [cell.commentText sizeToFit];
            [cell layoutSubviews];
            [cell updateConstraints];
            return  cell;
        }
        
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"commentFooter";
    AddCommentFooterCell* commentFooter = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (commentFooter != nil)
    {
        commentTextField = commentFooter.commentField;
        commentTextField.delegate = self;
        //commentFooter.footerView.layer.cornerRadius = 10.f;
        //commentFooter.commentButton.tag = section;
    }
    return commentFooter;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // check the cell type
    PFObject* story = [self.objects objectAtIndex:indexPath.row];
    NSString* commentText = [story objectForKey:@"commentText"];
    // return the height of the cell
    return [self getTextLength:commentText base:30];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 50.0f;
}

// Get text height for comment
-(CGFloat)getTextLength:(NSString*)text base:(CGFloat)base
{
    //set the desired size of your textbox
    CGSize constraint = CGSizeMake(223, MAXFLOAT);
    // Determine the text font to calculate height
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:13.0] forKey:NSFontAttributeName];
    //get the size of the text box
    CGRect textsize = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    // height is equal to the height of all lines plus some padding
    float textHeight = textsize.size.height + 10 + base;
    // set the height to that height, or to the minimum of 50 for one line
    textHeight = (textHeight < 40.0) ? 40.0 : textHeight;
    
    return textHeight;
    
}
// get height for story text
-(CGFloat)getStringHeight:(NSString*)text
{
    CGSize constraint = CGSizeMake(self.tableView.frame.size.width - 32, MAXFLOAT);
    // Determine the text font to calculate height
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0] forKey:NSFontAttributeName];
    //get the size of the text box
    CGRect textsize = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    float stringHeight = textsize.size.height;
    return stringHeight;
}


// get height for view
-(CGFloat)getViewHeight:(NSString*)text type:(NSString*)type
{
    // base = 88, like = 43
    float baseHeight = 88 + 43;
    // if story has media, add that height
    if (([type isEqualToString:@"photo"] || [type isEqualToString:@"video"]))
    {
        // add image height to the base
        baseHeight = baseHeight + 143.0;
    }
    // Set the text height to fit the story
    //NSString* storyText = [thisStory objectForKey:@"story"];
    //set the size of the textbox
    CGSize constraint = CGSizeMake(self.cellWidth - 32, MAXFLOAT);
    // Determine the text font to calculate height
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0] forKey:NSFontAttributeName];
    //get the size of the text box
    CGRect textsize = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    // height is equal to the height of all lines plus some padding
    float textHeight = textsize.size.height + 2 + baseHeight;
    return textHeight;
}

#pragma mark - Add Comment Text Field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString* trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.thisStory objectForKey:@"author"])
    {
        PFObject* newComment = [PFObject objectWithClassName:@"Activity"];
        [newComment setObject:trimmedComment forKey:@"commentText"];
        [newComment setObject:[self.thisStory objectForKey:@"author"] forKey:@"toUser"]; // Set toUser
        [newComment setObject:[PFUser currentUser] forKey:@"fromUser"]; // Set fromUser
        [newComment setObject:@"comment" forKey:@"activityType"];
        [newComment setObject:self.thisStory forKey:@"Testimony"];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        [ACL setWriteAccess:YES forUser:[self.thisStory objectForKey:@"author"]];
        newComment.ACL = ACL;
        
        //[[PAPCache sharedCache] incrementCommentCountForPhoto:self.thisStory];
        
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:@{@"comment": newComment} repeats:NO];
        
        [newComment saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate];
            
            if (error && error.code == kPFErrorObjectNotFound) {
                /*    [[PAPCache sharedCache] decrementCommentCountForPhoto:self.photo];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not post comment", nil) message:NSLocalizedString(@"This photo is no longer available", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                 [alert show];
                 [self.navigationController popViewControllerAnimated:YES];
                 */
            }
            /*
             [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:self.photo userInfo:@{@"comments": @(self.objects.count + 1)}];
             
             [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
             */
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
        }];
    }
    
    [textField setText:@""];
    return [textField resignFirstResponder];
}

- (void)handleCommentTimeout:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Comment", nil) message:NSLocalizedString(@"Your comment will be posted next time there is an Internet connection.", nil)  delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss", nil), nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

