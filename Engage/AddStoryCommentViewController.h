//
//  AddStoryCommentViewController.h
//  Test Engage
//
//  Created by Angela Smith on 8/18/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import "StoryDetailsInfoHeaderView.h"
#import "STTweetLabel.h"

@interface AddStoryCommentViewController : PFQueryTableViewController <UITextFieldDelegate>

@property (nonatomic, strong) PFObject* thisStory;
@property (nonatomic, strong) NSArray* storyLikers;
@property (nonatomic, strong) IBOutlet StoryDetailsInfoHeaderView* headerView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic, strong) IBOutlet UIView* likesView;
@property (nonatomic, strong) UIButton* likeStoryButton;
@property (nonatomic, strong) NSMutableArray *currentLikeAvatars;
@property (nonatomic, assign) BOOL likersQueryInProgress;

- (id)initWithStory:(PFObject*)story;


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

#define aPostClass  @"Testimony"
#define aActivityClass @"Activity"
#define aActivityType @"activityType"
#define aActivityFromUser @"UsersFullName"
#define aActivityToUser @"Group"
#define aActivityComment @"comment"
#define aActivityLike @"like"


@end
