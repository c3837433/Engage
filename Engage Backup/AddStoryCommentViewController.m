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

@interface AddStoryCommentViewController ()

@end

@implementation AddStoryCommentViewController
@synthesize headerView, thisStory, commentTextField;

- (id)initWithStory:(PFObject *)story {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // The className to query on
        self.parseClassName = @"Activity";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        // The number of comments to show per page
        self.objectsPerPage = 20;
        //self.thisStory = story;
        //self.likersQueryInProgress = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    if (userInfoView != nil)
    {
        [userInfoView setDetailHeaderInfo:thisStory];
        
    }
    [self.headerView addSubview:userInfoView];
    
    
    // ADD TEXT VIEW
    UIView* textView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, stringHeight)];
    UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0f, 0.0f, 268.0f, stringHeight)];
    //[textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:12.0f]];
    //[textLabel setTextColor:[UIColor darkGrayColor]];
    textView.backgroundColor = [UIColor whiteColor];
    if (textLabel != nil)
    {
        textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0f];
        textLabel.backgroundColor = [UIColor whiteColor];
        textLabel.textColor = [UIColor darkGrayColor];
        textLabel.text = storyText;
        [textLabel sizeToFit];
        [textLabel layoutSubviews];
        [textLabel updateConstraints];
    }
    // add label to view
    [textView addSubview:textLabel];
    // Add view to header
    [self.headerView addSubview:textView];
    
    CGRect textViewFrame = textView.frame;
    textViewFrame.origin.x = 13.0f;
    textViewFrame.origin.y = 86.0f;
    textViewFrame.size.width = 294.0f;
    textViewFrame.size.height = stringHeight + 20;
    textView.frame = textViewFrame;
    
    CGRect labelFrame = textLabel.frame;
    textViewFrame.origin.x = 25.0f;
    textViewFrame.origin.y = 86.0f;
    textViewFrame.size.width = 270.0f;
    textViewFrame.size.height = stringHeight + 20;
    textLabel.frame = labelFrame;
    
    // CHECK IF MEDIA IS NEEDED
    NSString* mediaType = [thisStory objectForKey:@"media"];
    if (([mediaType isEqualToString:@"photo"]) || ([mediaType isEqualToString:@"video"]))
    {
        // ADD USER MEDIA NIB
        NSArray* subviewArray2 = [[NSBundle mainBundle] loadNibNamed:@"StoryMediaView" owner:self options:nil];
        DetailStoryMediaView* storyMedia = [subviewArray2 objectAtIndex:0];
        if (storyMedia != nil)
        {
            [storyMedia setDetailStoryMedia:thisStory];
            CGRect mediaViewFrame  = storyMedia.frame;
            mediaViewFrame.origin.x = 0;
            mediaViewFrame.origin.y = 86 + stringHeight;
            storyMedia.frame = mediaViewFrame;
        }
        [self.headerView addSubview:storyMedia];
        
        
    }
    [self.headerView layoutSubviews];
    [self.headerView setNeedsDisplay];
    
    self.tableView.tableHeaderView = self.headerView;
    // Do any additional setup after loading the view.
}


- (PFQuery *)queryForTable {
    //NSLog(@"%@", self.thisStory);
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"Testimony" equalTo:self.thisStory];
    [query whereKey:@"activityType" equalTo:@"comment"];
    [query includeKey:@"fromUser"];
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
/*
 - (void)objectsDidLoad:(NSError *)error {
 [super objectsDidLoad:error];
 
 [self.headerView reloadLikeBar];
 [self loadLikers];
 }
 */
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
    CGSize constraint = CGSizeMake(268, MAXFLOAT);
    // Determine the text font to calculate height
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica Neue" size:12.0] forKey:NSFontAttributeName];
    //get the size of the text box
    CGRect textsize = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    float stringHeight = textsize.size.height;
    return stringHeight;
}

// get height for view
-(CGFloat)getViewHeight:(NSString*)text type:(NSString*)type
{
    float baseHeight = 86;
    // if story has media, add that height
    if (([type isEqualToString:@"photo"] || [type isEqualToString:@"video"]))
    {
        // add image height to the base
        baseHeight = baseHeight + 143.0;
    }
    // Set the text height to fit the story
    //NSString* storyText = [thisStory objectForKey:@"story"];
    //set the desired size of your textbox
    CGSize constraint = CGSizeMake(268, MAXFLOAT);
    // Determine the text font to calculate height
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica Neue" size:12.0f] forKey:NSFontAttributeName];
    //get the size of the text box
    CGRect textsize = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    // height is equal to the height of all lines plus some padding
    float textHeight = textsize.size.height + 20 + baseHeight;
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

