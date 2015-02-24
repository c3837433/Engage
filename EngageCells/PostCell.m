//
//  PostCell.m
//  EngageCells
//
//  Created by Angela Smith on 1/30/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "PostCell.h"
#import "STTweetLabel.h"
#import "Utility.h"

@interface PostCell ()
@property (weak, nonatomic) IBOutlet PFImageView* authorImage;
@property (weak, nonatomic) IBOutlet STTweetLabel* postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel* timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIButton* likeButton;
@property (weak, nonatomic) IBOutlet UIButton* commentButton;
@property (nonatomic) PFFile* profilePicture;

@end
/*
static CGFloat aPaddingDist = 6.0f;
static CGFloat aDefaultCommentCellHeight = 44.0f;
static CGFloat aTableViewWidth = -1;
static CGFloat aStandardButtonSize = 50.0f;
static CGFloat aStandardLabelHeight = 20.0f;
*/
#define aPostTextFont  [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12]
#define aPostTitleFont [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:15]
#define aPostTimestampFont [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:10]



@implementation PostCell

@synthesize sAuthorButton, sAvatarImageButton, sAvatarImageView, sLocalButton, sMainView, sStoryTextLabel, sTimeLabel, sTitleLabel, cellInsetWidth, postStory, storyAuthor, delegate;
/*
- (void)awakeFromNib
{
    [super awakeFromNib];
}
*/
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        cellInsetWidth =
        self.clipsToBounds = YES;
        horizontalTextSpace =  [PostCell horizontalTextSpaceForInsetWidth:cellInsetWidth];
        
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        
        // MAIN VIEW
        sMainView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [sMainView setBackgroundColor:[UIColor whiteColor]];
        
        // PROFILE PICTURE
        self.sAvatarImageView = [[ProfileImageView alloc] init];
        [self.sAvatarImageView setBackgroundColor:[UIColor clearColor]];
        [self.sAvatarImageView setOpaque:YES];
        self.sAvatarImageView.layer.cornerRadius = 16.0f;
        self.sAvatarImageView.layer.masksToBounds = YES;
        [sMainView addSubview:self.sAvatarImageView];
        
        // NAME BUTTON
        self.sAuthorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sAuthorButton setBackgroundColor:[UIColor clearColor]];
        
        [self.sAuthorButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.sAuthorButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];

        [self.sAuthorButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [self.sAuthorButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
       // [self.sAuthorButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [sMainView addSubview:self.sAuthorButton];
        
        // LOCAL BUTTON
        self.sLocalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sLocalButton setBackgroundColor:[UIColor clearColor]];
        
        [self.sLocalButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.sAuthorButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        
        [self.sLocalButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [self.sLocalButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        // [self.sAuthorButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [sMainView addSubview:self.sLocalButton];
        
        
        // TITLE TEXT
        self.sTitleLabel = [[UILabel alloc] init];
        [self.sTitleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [self.sTitleLabel setTextColor:[UIColor blackColor]];

        [self.sTitleLabel setNumberOfLines:0];
        [self.sTitleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.sTitleLabel setBackgroundColor:[UIColor clearColor]];
        [sMainView addSubview:self.sTitleLabel];

         // STORY TEXT // STTweetLabel* sStoryTextLabel;
         self.sStoryTextLabel = [[STTweetLabel alloc] init];
         [self.sStoryTextLabel setFont:[UIFont systemFontOfSize:13.0f]];
         [self.sStoryTextLabel setTextColor:[UIColor blackColor]];
         [self.sStoryTextLabel setNumberOfLines:0];
         [self.sStoryTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
         [self.sStoryTextLabel setBackgroundColor:[UIColor clearColor]];
         [sMainView addSubview:self.sStoryTextLabel];

        
        // TIME STAMP LABEL
        self.sTimeLabel = [[UILabel alloc] init];
        [self.sTimeLabel setFont:[UIFont systemFontOfSize:11]];
        [self.sTimeLabel setTextColor:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f]];
        [self.sTimeLabel setBackgroundColor:[UIColor clearColor]];
        [sMainView addSubview:self.sTimeLabel];
        
        // USER IMAGE
        self.sAvatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sAvatarImageButton setBackgroundColor:[UIColor clearColor]];
       // [self.sAvatarImageButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [sMainView addSubview:self.sAvatarImageButton];
        
        
        [self.contentView addSubview:sMainView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    // LAYOUT MAIN VIEW
    [sMainView setFrame:CGRectMake(cellInsetWidth, self.contentView.frame.origin.y, self.contentView.frame.size.width-2*cellInsetWidth, self.contentView.frame.size.height)];
    
     //LAYOUT PROFILE PICTURE
    [self.sAvatarImageView setFrame:CGRectMake(avatarX, avatarY + 5.0f, avatarDim, avatarDim)];
    [self.sAvatarImageButton setFrame:CGRectMake(avatarX, avatarY + 5.0f, avatarDim, avatarDim)];
    
    // LAYOUT NAME BUTTON
    CGSize nameSize = [self.sAuthorButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin // word wrap?
                                                                 attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                                                    context:nil].size;
    [self.sAuthorButton setFrame:CGRectMake(nameX, nameY + 6.0f, nameSize.width, nameSize.height)];
    
    // LAYOUT LOCAL BUTTON
    CGSize localSize = [self.sLocalButton.titleLabel.text boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                                       context:nil].size;
    [self.sLocalButton setFrame:CGRectMake(nameX, vertTextBorderSpacing + 5.0f, localSize.width, localSize.height)];
    /*
    // LAYOUT TITLE
    CGSize titleSize = [self.sTitleLabel.text boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                              context:nil].size;
    [self.sTitleLabel setFrame:CGRectMake(nameX, sLocalButton.frame.origin.y + sLocalButton.frame.size.height + vertElemSpacing, titleSize.width, titleSize.height)];
    
    // LAYOUT TEXT
    CGSize textSize = [self.sStoryTextLabel.text boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                           context:nil].size;
    [self.sStoryTextLabel setFrame:CGRectMake(nameX, sTitleLabel.frame.origin.y + sTitleLabel.frame.size.height + vertElemSpacing, textSize.width, textSize.height)];
    
    
    
    // LAYOUT TIME STAMP LABEL
    CGSize timeSize = [self.sTimeLabel.text boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}
                                                        context:nil].size;
    [self.sTimeLabel setFrame:CGRectMake(timeX, sStoryTextLabel.frame.origin.y + sStoryTextLabel.frame.size.height + vertElemSpacing, timeSize.width, timeSize.height)];

    
    
    
    // TITLE LABEL
    NSString* postTitle = [self.story objectForKey:aTitleKey];
    CGFloat titleHeight = [PostCell heightForTitle:postTitle];
    CGRect frame = self.titleLabel.frame;
    frame.origin.x = self.authorImage.frame.origin.x + self.authorImage.frame.size.width + aPaddingDist;
    frame.origin.y = self.authorImage.frame.origin.y;
    frame.size.height = titleHeight;
    self.titleLabel.frame = frame;
    
    // NAME BUTTON
    CGSize nameSize = [self.authorButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin // word wrap?
                                                                 attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                                                    context:nil].size;
    [self.authorButton setFrame:CGRectMake(nameX, nameY + 6.0f, nameSize.width, nameSize.height)];
    
    // HOME GROUP BUTTON
    CGSize contentSize = [self.localButton.titleLabel.text boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                              context:nil].size;
    [self.localButton setFrame:CGRectMake(nameX, vertTextBorderSpacing + 5.0f, contentSize.width, contentSize.height)];
    
    
    // AUTHOR BUTTON
    frame = self.authorButton.frame;
    frame.origin.x = self.titleLabel.frame.origin.x;
    frame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + aPaddingDist;
    PFUser* author = [self.story objectForKey:aUserKey];
    NSString* authorName = [author objectForKey:aAuthorName];
    CGFloat authorHeight = [PostCell heightForText:authorName];
    frame.size.height = authorHeight;
    self.authorButton.frame = frame;
    
    
    // POST TEXT LABEL
    NSString* postText = [self.story objectForKey:aStoryKey];
    CGFloat textHeight = [PostCell heightForText:postText] + aPaddingDist;
    frame = self.postTextLabel.frame;
    frame.origin.x = self.titleLabel.frame.origin.x;
    frame.origin.y = self.authorButton.frame.origin.y + self.authorButton.frame.size.height + aPaddingDist;
    frame.size.height = textHeight;
    self.postTextLabel.frame = frame;
    
    // TIME STAMP LABEL
    frame = self.timeStampLabel.frame;
    frame.origin.x = self.titleLabel.frame.origin.x;
    frame.origin.y = self.postTextLabel.frame.origin.y + self.postTextLabel.frame.size.height + aPaddingDist;
    self.timeStampLabel.frame = frame;
    
    // LIKE BUTTON
    frame = self.likeButton.frame;
    frame.origin.y = self.contentView.frame.origin.y + self.contentView.frame.size.height - frame.size.height - aPaddingDist;
    self.likeButton.frame = frame;
    [super layoutSubviews];
     */
}

#pragma mark - PAPBaseTextCell

/* Static helper to get the height for a cell if it had the given name and content */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [PostCell heightForCellWithName:name contentString:content cellInsetWidth:0];
}

/* Static helper to get the height for a cell if it had the given name, content and horizontal inset */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = [name boundingRectWithSize:nameSize
                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                         context:nil].size;
    
    NSString *paddedString = [PostCell padString:content withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [PostCell horizontalTextSpaceForInsetWidth:cellInset];
    
    CGSize contentSize = [paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin // word wrap?
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                    context:nil].size;
    
    CGFloat singleLineHeight = [@"test" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                     context:nil].size.height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = (contentSize.height - singleLineHeight) > 0 ? (contentSize.height - singleLineHeight) : 0;
    
    return horiBorderSpacing + avatarDim + horiBorderSpacingBottom + multilineHeightAddition;
}

/* Static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return (320-(insetWidth*2)) - (horiBorderSpacing+avatarDim+horiElemSpacing+horiBorderSpacing);
}

/* Static helper to pad a string with spaces to a given beginning offset */
+ (NSString *)padString:(NSString *)string withFont:(UIFont *)font toWidth:(CGFloat)width {
    // Find number of spaces to pad
    NSMutableString *paddedString = [[NSMutableString alloc] init];
    while (true) {
        [paddedString appendString:@" "];
        CGSize resultSize = [paddedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                       options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:font}
                                                       context:nil].size;
        if (resultSize.width >= width) {
            break;
        }
    }
    
    // Add final spaces to be ready for first word
    [paddedString appendString:[NSString stringWithFormat:@" %@",string]];
    return paddedString;
}


/*
+ (void)setTableViewWidth:(CGFloat)tableWidth {
    aTableViewWidth = tableWidth;
}
 */
/*
+ (id)storyPostCellForTableWidth:(CGFloat)width {
    // CREATE CELL
    PostCell* cell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:aCellIdentifier];
    CGRect cellFrame = cell.frame;
    cellFrame.size.width = width;
    cell.frame = cellFrame;
    
    // LEFT SIDE AUTHOR PICTURE
    PFImageView *authorImagView = [[PFImageView alloc] initWithFrame:CGRectMake(aPaddingDist, aPaddingDist, aStandardButtonSize, aStandardButtonSize)];
    authorImagView.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:authorImagView];
    cell.authorImage = authorImagView;
    
    // LIKE BUTTON OFF TO RIGHT SIDE
    UIButton *likeButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width - (aPaddingDist + aStandardButtonSize), aPaddingDist, aStandardButtonSize, 38)];
    [likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [cell addSubview:likeButton];
    cell.likeButton = likeButton;
    
    // TITLE LABEL AT TOP OF CELL
    CGRect titleLabelRect = CGRectMake(authorImagView.frame.origin.x + authorImagView.frame.size.width + aPaddingDist,
                                  authorImagView.frame.origin.y,
                                  likeButton.frame.origin.x - (aPaddingDist * 3 + authorImagView.frame.size.width),
                                  aStandardLabelHeight);
    
    UILabel* postTitleLabel = [[UILabel alloc] initWithFrame:titleLabelRect];
    postTitleLabel.font = aPostTitleFont;
    postTitleLabel.textColor = [UIColor darkGrayColor];
    postTitleLabel.textAlignment = NSTextAlignmentLeft;
    postTitleLabel.numberOfLines = 0;
    postTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    postTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.titleLabel = postTitleLabel;
    [cell addSubview:postTitleLabel];
    
    

    //CREATE AUTHOR BUTTON UNDER TITLE
    cell.authorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cell.authorButton setBackgroundColor:[UIColor clearColor]];
    [cell.authorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cell.authorButton setTitleColor:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];

    [cell.authorButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [cell.authorButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    //[cell.authorButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview: cell.authorButton];
*/
    /*
    CGRect authorButtonFrame = CGRectMake(postTitleLabel.frame.origin.x,
                                     authorImagView.frame.origin.y,
                                     likeButton.frame.origin.x - (aPaddingDist * 3 + authorImagView.frame.size.width),
                                     aStandardLabelHeight);
    UIButton* authorBtn = [[UIButton alloc] initWithFrame:authorButtonFrame];
    [cell addSubview:authorBtn];
    cell.authorButton = authorBtn;

    */
     /*
    // POST TEXT LABEL
    CGRect labelRect = CGRectMake(postTitleLabel.frame.origin.x,
                                  postTitleLabel.frame.origin.y + postTitleLabel.frame.size.height,
                                  likeButton.frame.origin.x - (aPaddingDist * 3 + authorImagView.frame.size.width),
                                  aStandardLabelHeight);
    STTweetLabel *postLabel = [[STTweetLabel alloc] initWithFrame:labelRect];
    postLabel.font = aPostTextFont;
    postLabel.textColor = [UIColor lightGrayColor];
    postLabel.textAlignment = NSTextAlignmentLeft;
    postLabel.numberOfLines = 0;
    postLabel.lineBreakMode = NSLineBreakByWordWrapping;
    postLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.postTextLabel = postLabel;
    [cell addSubview:postLabel];
    
    // Create TIME STAMP LABEL UNDER POST TEXT
    UILabel* timeStampLab = [[UILabel alloc] initWithFrame:CGRectMake(postLabel.frame.origin.x, postLabel.frame.origin.y + postLabel.frame.size.height + aPaddingDist, postLabel.frame.size.width, postLabel.frame.size.height)];
    timeStampLab.font = aPostTimestampFont;
    timeStampLab.textColor = [UIColor grayColor];
    timeStampLab.textAlignment = NSTextAlignmentLeft;
    cell.timeStampLabel = timeStampLab;
    [cell addSubview:timeStampLab];
    
    return cell;

    
}
 */

/*
- (void)setCellInsetWidth:(CGFloat)insetWidth {
         // Change the mainView's frame to be insetted by insetWidth and update the content text space
         cellInsetWidth = insetWidth;
         [sMainView setFrame:CGRectMake(insetWidth, sMainView.frame.origin.y, sMainView.frame.size.width-2*insetWidth, sMainView.frame.size.height)];
         horizontalTextSpace = [PostCell horizontalTextSpaceForInsetWidth:insetWidth];
         [self setNeedsDisplay];
}

+ (CGFloat)cellHeightForCell:(NSString *)text title:(NSString *)title {
    return aDefaultCommentCellHeight + [PostCell heightForText:text] + [PostCell heightForTitle:title] + aPaddingDist;
}

+ (CGFloat)heightForTitle:(NSString *)title
{
    CGFloat height = 0.0;
    CGFloat textlabelWidth = aTableViewWidth - 2 * (aStandardButtonSize + aPaddingDist);
    CGRect rect = [title boundingRectWithSize:(CGSize){textlabelWidth, MAXFLOAT}
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:aPostTitleFont}
                                     context:nil];
    height = rect.size.height;
    return height;
}

+ (CGFloat)heightForText:(NSString *)text
{
    CGFloat height = 0.0;
    CGFloat textlabelWidth = aTableViewWidth - 2 * (aStandardButtonSize + aPaddingDist);
    CGRect rect = [text boundingRectWithSize:(CGSize){textlabelWidth, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:aPostTextFont}
                                        context:nil];
    height = rect.size.height + aPaddingDist;
    return height;
}
*/
/* Static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration */

/*
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return (320-(insetWidth*2)) - (horiBorderSpacing+avatarDim+horiElemSpacing+horiBorderSpacing);
}
*/

- (void)configurePostCellForStory:(PFObject *)story {

    // GET THE STORY
    self.postStory = story;
    // SET AUTHOR PICTURE
    self.storyAuthor = [self.postStory objectForKey:@"author"];
    // Set name button properties and avatar image
    if ([Utility userHasProfilePictures:storyAuthor]) {
        [self.sAvatarImageView setFile:[storyAuthor objectForKey:@"ProfilePictureSmall"]];
    } else {
        [self.sAvatarImageView setImage:[Utility defaultProfilePicture]];
    }

    
    // SET AUTHOR NAME
    [self.sAuthorButton setTitle:[storyAuthor objectForKey:@"UsersFullName"] forState:UIControlStateNormal];
    //NSLog(@"Users name = %@", [storyAuthor objectForKey:@"UsersFullName"] );
    [self.sAuthorButton setTitle:[storyAuthor objectForKey:@"UsersFullName"] forState:UIControlStateHighlighted];
    
    // SET LOCAL GROUP
    if ([self.postStory objectForKey:@"Group"]) {
        PFObject* group = [self.postStory  objectForKey:@"Group"];
        [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.sLocalButton setTitle:[group objectForKey:@"groupHeader"] forState:UIControlStateNormal];
            [self.sLocalButton setTitle:[group objectForKey:@"groupHeader"] forState:UIControlStateHighlighted];
            //homeGroupLabel.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
            [self.sLocalButton sizeToFit];
        }];
    }
/*
    // SET TITLE AND TEXT
    self.sTitleLabel.text = [self.postStory objectForKey:@"title"];
    self.sStoryTextLabel.text = [self.postStory  objectForKey:@"story"];
    
    // SET TIME STAMP
    NSDate* timeCreated = self.postStory .createdAt;
    // Set the time interval
    Utility* utility = [[Utility alloc] init];
    NSString* timeStampString = [utility stringForTimeIntervalSinceCreated:timeCreated];
    sTimeLabel.text = timeStampString;
    */
     [self setNeedsDisplay];
    /*
    // SET THE TEXT
    self.postTextLabel.text = [story objectForKey:aStoryKey];

    // GET TIME STAMP
    NSDate* timeCreated = story.createdAt;
    // Set the time interval
    Utility* utility = [[Utility alloc] init];
    NSString* timeStampString = [utility stringForTimeIntervalSinceCreated:timeCreated];
    self.timeStampLabel.text = timeStampString;

    // SET TITLE
    self.titleLabel.text = [story objectForKey:aTitleKey];
    
    // SET THE AUTHOR
    PFUser* user = [story objectForKey:aUserKey];
    [self.authorButton setTitle:[user objectForKey:aAuthorName] forState:UIControlStateNormal];
    [self.authorButton setTitle:[user objectForKey:aAuthorName] forState:UIControlStateHighlighted];
    
    self.authorImage.layer.cornerRadius = 8;
    self.authorImage.file = [user objectForKey:aProfilePictureId];
    [self.authorImage loadInBackground];
    self.authorImage.clipsToBounds = YES;
    
    [self setNeedsLayout];
     */
    
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    // Change the mainView's frame to be insetted by insetWidth and update the content text space
    cellInsetWidth = insetWidth;
    [sMainView setFrame:CGRectMake(insetWidth, sMainView.frame.origin.y, sMainView.frame.size.width-2*insetWidth, sMainView.frame.size.height)];
    horizontalTextSpace = [PostCell horizontalTextSpaceForInsetWidth:insetWidth];
    [self setNeedsDisplay];
}

/* Since we remove the compile-time check for the delegate conforming to the protocol
 in order to allow inheritance, we add run-time checks. */
- (id<PostCellDelegate>)delegate {
    return (id<PostCellDelegate>)delegate;
}

- (void)setDelegate:(id<PostCellDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}


@end
