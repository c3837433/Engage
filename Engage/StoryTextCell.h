//
//  StoryTextCell.h
//  Engage
//
//  Created by Angela Smith on 8/15/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "STTweetLabel.h"

@protocol TextStoryFooterDelegate;

@interface StoryTextCell : PFTableViewCell

@property (nonatomic, strong) IBOutlet PFImageView* authorPic;
@property (nonatomic, strong) IBOutlet UILabel* storyTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeStampSinceCreationLabel;
@property (nonatomic, strong) IBOutlet UILabel* storyAuthorLabel;
@property (nonatomic, strong) IBOutlet STTweetLabel* storyTextLabel;
@property (nonatomic, strong) IBOutlet UIView* backgroundView;
@property (nonatomic, strong) IBOutlet UIButton* homeGroupLabel;
@property (nonatomic, strong) IBOutlet UIButton* likeButton;
@property (nonatomic, strong) IBOutlet UIButton* commentButton;
@property (nonatomic, strong) IBOutlet UIButton* totalLikesCommentsButton;
@property (nonatomic, strong) IBOutlet PFObject* thisStory;

@property (nonatomic,weak) id <TextStoryFooterDelegate> delegate;

-(void)setTextStory:(PFObject*)story;
- (void)setLikeStatus:(BOOL)liked;
- (void)shouldEnableLikeButton:(BOOL)enable;
@end

@protocol TextStoryFooterDelegate <NSObject>

@optional
- (IBAction)storyActionFooter:(StoryTextCell*)storyActionFooter didTapTextLikeStoryButton:(UIButton *)button story:(PFObject *)story;

@end