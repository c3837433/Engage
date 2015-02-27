//
//  TextCommentDetailViewController.m
//  Engage
//
//  Created by Angela Smith on 2/16/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "TextCommentDetailViewController.h"
#import "UserDetailsViewController.h"
#import "ApplicationKeys.h"
#import "Utility.h"
#import "Cache.h"
#import "CommentCell.h"
#import "AddCommentFooterCell.h"
#import "MBProgressHUD.h"


@interface TextCommentDetailViewController ()

@end

@implementation TextCommentDetailViewController

@synthesize  thisStory, commentTextField, likesView, likeStoryButton, storyLikers, currentLikeAvatars, storyDetailView, postAuthorGroupButton, postAuthorImage, postStoryLabel, postTitleLabel, postAuthorNameButton, postTimeStampLabel, firstLikesButton, andLikesLabel, extraLikesButton;

- (id)initWithStory:(PFObject *)story {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
       // self.thisStory = story;
        story = self.thisStory;
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
    // set up the story properties for the header
    
    // get the cell width
    self.cellWidth = self.tableView.frame.size.width;
    
    // BUILD THE STORY HEADER
    // get the height of the View

    NSString* storyText = [thisStory objectForKey:@"story"];
    //float textHeight = [self getViewHeight:storyText];
    float stringHeight = [self getStringHeight:storyText];

    // Update the frames
    CGRect textViewFrame = storyDetailView.frame;
    textViewFrame.origin.x = storyDetailView.frame.origin.x;
    textViewFrame.origin.y = storyDetailView.frame.origin.y;
    textViewFrame.size.width = storyDetailView.frame.size.width;
    textViewFrame.size.height = 161 - 23 + stringHeight;
    storyDetailView.frame = textViewFrame;
    
    CGRect labelFrame = postStoryLabel.frame;
    textViewFrame.origin.x = postStoryLabel.frame.origin.x;
    textViewFrame.origin.y = postStoryLabel.frame.origin.y;
    textViewFrame.size.width = postStoryLabel.frame.size.width;
    textViewFrame.size.height = stringHeight;
    postStoryLabel.frame = labelFrame;
    
    self.tableView.tableHeaderView = storyDetailView;
    [storyDetailView layoutSubviews];
    [storyDetailView setNeedsDisplay];
    
    
    self.tableView.estimatedRowHeight = 56;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
     [self setStory];
    // [likeStoryButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
  
   [self reloadLikeBar];
}


- (PFQuery *)queryForTable {

    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"onStory" equalTo:self.thisStory];
    [query includeKey:@"fromUser"];
    [query orderByAscending:@"createdAt"];
    
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
   // [self setStory];
    self.tableView.estimatedRowHeight = 56;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

}


- (void)loadLikers {
    // see if we have likers
    if (self.likersQueryInProgress) {
        return;
    }
    
    self.likersQueryInProgress = YES;
    // get the likers
    PFQuery* likerQuery = [Utility queryForLikersForStory:thisStory cachePolicy:kPFCachePolicyNetworkOnly];
    [likerQuery findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        self.likersQueryInProgress = NO;
        if (error) {
            [self reloadLikeBar];
            return;
        }
        
        NSMutableArray *likers = [NSMutableArray array];
        BOOL isLikedByCurrentUser = NO;
        
        for (PFObject* liker in objects) {
            // see if the story is liked by the current user
            if ([[[liker objectForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                isLikedByCurrentUser = YES;
            }
            // add the liker to the liker list
            [likers addObject:[liker objectForKey:@"fromUser"]];

        }
        [[Cache sharedCache] setLikeAttributesForStory:thisStory likers:likers likedByCurrentUser:isLikedByCurrentUser];
        [self reloadLikeBar];
  }];
}

- (void)setLikeUsers:(NSArray*)anArray {

    [likeStoryButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)storyLikers.count] forState:UIControlStateNormal];
    
    NSInteger numOfLikes = storyLikers.count;
    if (!numOfLikes == 0) {
        // we have likes
        // get that person's name and set it to the button
        PFUser* firstUser = [storyLikers objectAtIndex:0];
        // get that person's name and set it to the button
        [firstLikesButton setTitle:[firstUser objectForKey:aUserName] forState:UIControlStateNormal];
        [firstLikesButton setTitle:[firstUser objectForKey:aUserName] forState:UIControlStateHighlighted];
        if (numOfLikes == 1) {
            andLikesLabel.hidden = YES;
            extraLikesButton.hidden = YES;
        } else {
            NSString* extraTitleString;
            // we have more than one
            if (numOfLikes == 2) {
                // one other
                extraTitleString = [NSString stringWithFormat:@"%lu other like this", numOfLikes - 1];
            } else {
                // multiple others
                extraTitleString = [NSString stringWithFormat:@"%lu others like this", numOfLikes - 1];
            }
            [extraLikesButton setTitle:extraTitleString forState:UIControlStateNormal];
            [extraLikesButton setTitle:extraTitleString forState:UIControlStateHighlighted];
        }
    } else {
        // hide buttons and label
        firstLikesButton.hidden = YES;
        andLikesLabel.hidden = YES;
        extraLikesButton.hidden = YES;
    }
}

-(void)setStory {

    [self.thisStory fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            [self setUpStoryView:object];
        }
    }];
}

-(void)setUpStoryView:(PFObject*) story {
    self.thisStory = nil;
    self.thisStory = story;
    // SET AUTHOR PICTURE
    PFUser* thisPostAuthor = [thisStory objectForKey:aPostAuthor];
    //NSLog(@"This user = %@", thisPostAuthor);
    if ([thisPostAuthor objectForKey:aUserImage]) {
      //  NSLog(@"This user has image");
        PFFile* imageFile = [thisPostAuthor objectForKey:aUserImage];
        if ([imageFile isDataAvailable]) {
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
    
    // SET AUTHOR NAME
    [postAuthorNameButton setTitle:[thisPostAuthor objectForKey:aUserName] forState:UIControlStateNormal];
    [postAuthorNameButton setTitle:[thisPostAuthor objectForKey:aUserName] forState:UIControlStateHighlighted];
    
    // SET LOCAL GROUP
    if ([thisStory objectForKey:aPostAuthorGroup]) {
        PFObject* group = [thisStory  objectForKey:aPostAuthorGroup];
        [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [postAuthorGroupButton setTitle:[group objectForKey:aPostAuthorGroupTitle] forState:UIControlStateNormal];
            [postAuthorGroupButton setTitle:[group objectForKey:aPostAuthorGroupTitle] forState:UIControlStateHighlighted];
        }];
    } else {
        postAuthorGroupButton.hidden = YES;
    }
    // SET TIME STAMP
    NSDate* timeCreated = thisStory.createdAt;
    // Set the time interval
    Utility* utility = [[Utility alloc] init];
    NSString* timeStampString = [utility stringForTimeIntervalSinceCreated:timeCreated];
    postTimeStampLabel.text = timeStampString;
    
    // SET TITLE AND TEXT
    postTitleLabel.text = [thisStory objectForKey:aPostTitle];
    postStoryLabel.text = [thisStory  objectForKey:aPostText];
    
    [likeStoryButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)storyLikers.count] forState:UIControlStateNormal];
    NSInteger numOfLikes = storyLikers.count;
    if (!numOfLikes == 0) {
        // we have likes
        // get that person's name and set it to the button
        PFUser* firstUser = [storyLikers objectAtIndex:0];
        // get that person's name and set it to the button
        [firstLikesButton setTitle:[firstUser objectForKey:aUserName] forState:UIControlStateNormal];
        [firstLikesButton setTitle:[firstUser objectForKey:aUserName] forState:UIControlStateHighlighted];
        // Add like action
        [firstLikesButton addTarget:self action:@selector(onFirstLikeUserButtonClick) forControlEvents:UIControlEventTouchUpInside];
        if (numOfLikes == 1) {
            andLikesLabel.text = @"likes this";
            extraLikesButton.hidden = YES;
        } else {
            NSString* extraTitleString;
            // we have more than one
            if (numOfLikes == 2) {
                // one other
                extraTitleString = [NSString stringWithFormat:@"%lu other like this", numOfLikes - 1];
            } else {
                // multiple others
                extraTitleString = [NSString stringWithFormat:@"%lu others like this", numOfLikes - 1];
            }
            [extraLikesButton setTitle:extraTitleString forState:UIControlStateNormal];
            [extraLikesButton setTitle:extraTitleString forState:UIControlStateHighlighted];
        }
    } else {
        // hide buttons and label
        firstLikesButton.hidden = YES;
        andLikesLabel.hidden = YES;
        extraLikesButton.hidden = YES;
    }
    // Add like action
    // [self.likeButton addTarget:self action:@selector(didTapTextLikeStoryButton:) forControlEvents:UIControlEventTouchUpInside];

}
- (void)detailCommentCell:(CommentCell *)detailCommentCell didTapUserButton:(UIButton *)button user:(PFUser *)user {
    NSLog(@"User tapped user image or user name: %@", user);
    UserDetailsViewController* userDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"userDetailsVc"];
    userDetailsVC.fromPanel = false;
    userDetailsVC.thisUser = user;
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}

-(void)onFirstLikeUserButtonClick {
    PFUser* user = [storyLikers objectAtIndex:0];
    NSLog(@"User tapped first liker name: %@", user);
    UserDetailsViewController* userDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"userDetailsVc"];
    userDetailsVC.fromPanel = false;
    userDetailsVC.thisUser = user;
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}

-(IBAction)onLikeListClick:(UIButton*)button {
    
    
}

-(IBAction)onPostUserClick:(UIButton*)button {
    UserDetailsViewController* userDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"userDetailsVc"];
    userDetailsVC.fromPanel = false;
    userDetailsVC.thisUser = [thisStory objectForKey:aPostAuthor];;
    [self.navigationController pushViewController:userDetailsVC animated:YES];
    
}
- (IBAction)onHomeGroupClick:(id)sender {
    PFObject* thisGroup = [thisStory objectForKey:aPostAuthorGroup];
    NSLog(@"User clicked group: %@", thisGroup);
    
}




#pragma mark - Segue Methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton*)sender
{
    if ([segue.identifier isEqualToString:@"segueToComment"])
    {
       // PFObject* story = [self.objects objectAtIndex:sender.tag];
       // AddStoryCommentViewController* addCommentVC = segue.destinationViewController;
       // addCommentVC.thisStory = story;
    }
    else if ([segue.identifier isEqualToString:@"textSegueToComment"])
    {
        //PFObject* story = [self.objects objectAtIndex:sender.tag];
       // AddStoryCommentViewController* addCommentVC = segue.destinationViewController;
        //addCommentVC.thisStory = story;
    }
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
   // [self setLikeUsers:storyLikers];
    [self setLikeButtonState:[[Cache sharedCache] isPhotoLikedByCurrentUser:thisStory]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    if (indexPath.row == self.objects.count) {
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    else {
        CommentCell* cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        if (cell != nil) {
            [cell setComment:object];
            cell.delegate = self;
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
    }
    return commentFooter;
    
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
-(CGFloat)getViewHeight:(NSString*)text
{
    // base = 88, like = 43
    float baseHeight = 88 + 43;
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
    if ([textField.text isEqualToString:@""]) {
        [self.tableView reloadData];
        return [textField resignFirstResponder];
    } else {
    NSString* trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.thisStory objectForKey:@"author"])
    {
        PFObject* newComment = [PFObject objectWithClassName:@"Comment"];
        [newComment setObject:trimmedComment forKey:@"message"];
        [newComment setObject:[self.thisStory objectForKey:@"author"] forKey:@"toUser"]; // Set toUser
        [newComment setObject:[PFUser currentUser] forKey:@"fromUser"]; // Set fromUser
        //[newComment setObject:@"comment" forKey:@"activityType"];
        [newComment setObject:self.thisStory forKey:@"onStory"];

        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        [ACL setWriteAccess:YES forUser:[self.thisStory objectForKey:@"author"]];
        [ACL setWriteAccess:true forRoleWithName:@"Admin"];
        [ACL setWriteAccess:true forUser:[PFUser currentUser]];
        [ACL setWriteAccess:true forRoleWithName:@"GroupLead"];
        newComment.ACL = ACL;
        
        [[Cache sharedCache] incrementCommentCountForPhoto:self.thisStory];
        
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:@{@"comment": newComment} repeats:NO];
        
        [newComment saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate];
            
            if (error && error.code == kPFErrorObjectNotFound) {
                 [[Cache sharedCache] decrementCommentCountForPhoto:self.thisStory];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not post comment", nil) message:NSLocalizedString(@"This story is no longer available", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                 [alert show];
                 [self.navigationController popViewControllerAnimated:YES];
                
            }
            /*
             [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:self.photo userInfo:@{@"comments": @(self.objects.count + 1)}];
            
             */
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
        }];
    }
    [textField setText:@""];
    return [textField resignFirstResponder];
    }
}

// Listen for when the user clicks off one of the text fields
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Close the keyboard
   [commentTextField resignFirstResponder];
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
