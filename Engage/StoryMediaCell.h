//
//  StoryMediaCell.h
//  Engage
//
//  Created by Angela Smith on 8/15/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import "STTweetLabel.h"
#import <ParseUI/ParseUI.h>
@protocol MediaStoryFooterDelegate;

@interface StoryMediaCell : PFTableViewCell

@property (nonatomic, strong) IBOutlet PFImageView* authorPic;
@property (nonatomic, strong) IBOutlet UILabel* storyTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeStampSinceCreationLabel;
@property (nonatomic, strong) IBOutlet UILabel* storyAuthorLabel;
@property (nonatomic, strong) IBOutlet STTweetLabel* mediaStoryTextLabel;
@property (nonatomic, strong) IBOutlet PFImageView* storyMediaThumb;
@property (nonatomic, strong) IBOutlet UIView* backgroundView;
@property (nonatomic, strong) IBOutlet UIButton* playButton;
@property (nonatomic, strong) IBOutlet UIButton* homeGroupLabel;
@property (nonatomic, strong) IBOutlet UIButton* likeButton;
@property (nonatomic, strong) IBOutlet UIButton* commentButton;
@property (nonatomic, strong) IBOutlet PFObject* thisStory;

@property (nonatomic,weak) id <MediaStoryFooterDelegate> delegate;

-(void)setMediaStory:(PFObject*)story;
- (void)setLikeStatus:(BOOL)liked;
- (void)shouldEnableLikeButton:(BOOL)enable;
@end

@protocol MediaStoryFooterDelegate <NSObject>
@optional
- (IBAction)storyActionFooter:(StoryMediaCell*)storyActionFooter didTapLikeMediaStoryButton:(UIButton *)button story:(PFObject *)story;
@end
