//
//  DetailStoryHeaderView.h
//  Engage
//
//  Created by Angela Smith on 7/21/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "STTweetLabel.h"

@interface DetailStoryHeaderView : UIView
@property (nonatomic, strong) IBOutlet UILabel* storyAuthor;
@property (nonatomic, strong) IBOutlet UILabel* storyTime;
@property (nonatomic, strong) IBOutlet UILabel* storyTitle;
@property (nonatomic, strong) IBOutlet UILabel* storyGroup;
@property (nonatomic, strong) IBOutlet STTweetLabel* textLabel;
@property (nonatomic, strong) IBOutlet UIButton* storyAuthorButton;
@property (nonatomic, strong) IBOutlet UIButton* storyGroupButton;
@property (nonatomic, strong) IBOutlet PFImageView* storyAuthorPic;
@property (nonatomic, strong) IBOutlet UIButton* userButton;


-(void)setDetailHeaderInfo:(PFObject*)story;
+ (id)detailHeaderView;

#pragma mark SAYING CLASS KEYS
#define aPostAuthor  @"author"
#define aPostAuthorImage @"profilePictureSmall"
#define aPostAuthorName @"UsersFullName"
#define aPostAuthorGroup @"Group"
#define aPostAuthorGroupTitle @"groupHeader"
#define aPostTitle @"title"
#define aPostText @"story"
#define aPostLikes @"Likes"
#define aPostComments @"Comments"
@end
