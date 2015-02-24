//
//  PostTextCell.h
//  EngageCells
//
//  Created by Angela Smith on 2/15/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "STTweetLabel.h"
#import "ProfileImageView.h"

@interface PostTextCell : PFTableViewCell
/*
@property (nonatomic, strong) IBOutlet UIButton* sAvatarImageButton;
@property (nonatomic, strong) IBOutlet ProfileImageView* sAvatarImageView;
@property (weak, nonatomic) IBOutlet UIButton* sAuthorButton;
@property (weak, nonatomic) IBOutlet UIButton* sLocalButton;
@property (nonatomic, strong) IBOutlet UILabel* sTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel* sTitleLabel;
@property (nonatomic, strong) IBOutlet STTweetLabel* sStoryTextLabel;
@property (weak, nonatomic) IBOutlet UIButton* sLikeButton;
@property (weak, nonatomic) IBOutlet UIButton* sCommentButton;
*/
@property (nonatomic, strong) IBOutlet UILabel* postTitleLabel;
@property (nonatomic, strong) IBOutlet STTweetLabel* postStoryLabel;
@property (nonatomic, strong) IBOutlet UILabel* postTimeStampLabel;
@property (nonatomic, strong) IBOutlet UIButton* postAuthorNameButton;
@property (nonatomic, strong) IBOutlet UIButton* postAuthorPicButton;
@property (nonatomic, strong) IBOutlet UIButton* postAuthorGroupButton;
@property (nonatomic, strong) IBOutlet PFImageView* postAuthorImage;
//@property (nonatomic, strong) IBOutlet PFImageView* postImage;
@property (weak, nonatomic) IBOutlet UIButton* likeButton;
@property (weak, nonatomic) IBOutlet UIButton* commentButton;
@property (nonatomic, strong) IBOutlet UIView* backgroundView;


@property (nonatomic, strong) IBOutlet PFObject* thisPost;
@property (nonatomic, strong) IBOutlet PFUser* thisPostAuthor;


-(void)setPost:(PFObject*)post;


#pragma mark SAYING CLASS KEYS
#define aPostAuthor  @"author"
#define aPostAuthorImage @"profilePictureSmall"
#define aPostAuthorName @"UsersFullName"
#define aPostAuthorGroup @"Group"
#define aPostAuthorGroupTitle @"groupHeader"
#define aPostTitle @"title"
#define aPostText @"story"

@end
