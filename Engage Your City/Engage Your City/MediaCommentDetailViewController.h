//
//  MediaCommentDetailViewController.h
//  Engage
//
//  Created by Angela Smith on 2/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "STTweetLabel.h"
#import <Parse/Parse.h> 
#import "CommentCell.h"

@interface MediaCommentDetailViewController : PFQueryTableViewController <UITextFieldDelegate, CommentCellDelegate>

@property (nonatomic, strong) PFObject* thisStory;
@property (nonatomic, strong) NSArray* storyLikers;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic, strong) IBOutlet UIView* likesView;
@property (nonatomic, strong) IBOutlet UIView* storyDetailView;
//@property (nonatomic, strong) UIButton* likeStoryButton;
@property (nonatomic, strong) NSMutableArray *currentLikeAvatars;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@property (nonatomic, strong) IBOutlet UILabel* postTitleLabel;
@property (nonatomic, strong) IBOutlet STTweetLabel* postStoryLabel;
@property (nonatomic, strong) IBOutlet UILabel* postTimeStampLabel;
@property (nonatomic, strong) IBOutlet UIButton* postAuthorNameButton;
@property (nonatomic, strong) IBOutlet UIButton* postAuthorPicButton;
@property (nonatomic, strong) IBOutlet UIButton* postAuthorGroupButton;
@property (nonatomic, strong) IBOutlet UIButton* firstLikesButton;
@property (nonatomic, strong) IBOutlet UILabel* andLikesLabel;
@property (nonatomic, strong) IBOutlet UIButton* extraLikesButton;
@property (nonatomic, strong) IBOutlet PFImageView* postAuthorImage;
@property (nonatomic, strong) IBOutlet PFImageView* postImage;
@property (weak, nonatomic) IBOutlet UIButton* likeButton;
@property (weak, nonatomic) IBOutlet UIButton* playButton;



- (id)initWithStory:(PFObject*)story;

@end
