//
//  PostTextCell.h
//  EngageCells
//
//  Created by Angela Smith on 2/15/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "STTweetLabel.h"
#import "ProfileImageView.h"

@protocol PostTextCellDelegate;

@interface PostTextCell : PFTableViewCell

@property (nonatomic, strong) IBOutlet UILabel* postTitleLabel;
@property (nonatomic, strong) IBOutlet STTweetLabel* postStoryLabel;
@property (nonatomic, strong) IBOutlet UILabel* postTimeStampLabel;
@property (nonatomic, strong) IBOutlet UIButton* postAuthorNameButton;
@property (nonatomic, strong) IBOutlet UIButton* postAuthorPicButton;
@property (nonatomic, strong) IBOutlet UIButton* postAuthorGroupButton;
@property (nonatomic, strong) IBOutlet PFImageView* postAuthorImage;
@property (weak, nonatomic) IBOutlet UIButton* likeButton;
@property (weak, nonatomic) IBOutlet UIButton* commentButton;
@property (weak, nonatomic) IBOutlet UIButton* likesCommentsButton;
@property (weak, nonatomic) IBOutlet UIButton* optionsButton;

@property (nonatomic, strong) IBOutlet UIView* backgroundView;


@property (nonatomic, strong) PFObject* thisPost;
@property (nonatomic, strong) PFObject* thisAuthorGroup;
@property (nonatomic, strong) PFUser* thisPostAuthor;


-(void)setUpStory:(PFObject*)post;

@property (nonatomic,weak) id <PostTextCellDelegate> delegate;

- (void)setLikeStatus:(BOOL)liked;
- (void)shouldEnableLikeButton:(BOOL)enable;
@end

@protocol PostTextCellDelegate <NSObject>

@optional
//- (IBAction)postTextCell:(PostTextCell*)postTextCell didTapTextLikeStoryButton:(UIButton *)button story:(PFObject *)story;
- (void)postTextCell:(PostTextCell*)postTextCell didTapUserButton:(UIButton *)button user:(PFUser *)user;
- (void)postTextCell:(PostTextCell*)postTextCell didTapLikeTextStoryButton:(UIButton *)button story:(PFObject *)story;
- (void)postTextCell:(PostTextCell*)postTextCell didTapHomeGroupButton:(UIButton *)button group:(PFObject *)group;
- (void)postTextCell:(PostTextCell*)postTextCell didTapOptionsButton:(UIButton *)button story:(PFObject *)story;

@end
