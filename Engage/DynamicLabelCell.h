//
//  DynamicLabelCell.h
//  EngageCells
//
//  Created by Angela Smith on 2/5/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import "STTweetLabel.h"
#import "ProfileImageView.h"

@protocol DynamicLabelCellDelegate;

@interface DynamicLabelCell : PFTableViewCell


@property (nonatomic, strong) IBOutlet UILabel* postTitleLabel;
@property (nonatomic, strong) IBOutlet STTweetLabel* postStoryLabel;
@property (nonatomic, strong) IBOutlet UILabel* postTimeStampLabel;
@property (nonatomic, strong) IBOutlet UIButton* postAuthorButton;
@property (nonatomic, strong) IBOutlet UIButton* postAuthorGroupButton;
@property (nonatomic, strong) IBOutlet PFImageView* postAuthorImage;
@property (nonatomic, strong) IBOutlet PFImageView* postImage;

@property (nonatomic, strong) IBOutlet UIButton* postLikeButton;
@property (nonatomic, strong) IBOutlet UIButton* postCommentButton;

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

@property (nonatomic,weak) id <DynamicLabelCellDelegate> delegate;

- (void)setLikeStatus:(BOOL)liked;
- (void)shouldEnableLikeButton:(BOOL)enable;
@end

@protocol DynamicLabelCellDelegate <NSObject>

@optional
- (IBAction)storyActionFooter:(DynamicLabelCell*)storyActionFooter didTapTextLikeStoryButton:(UIButton *)button story:(PFObject *)story;


@end
