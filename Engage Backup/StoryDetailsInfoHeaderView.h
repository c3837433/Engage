//
//  StoryDetailsInfoHeaderView.h
//  Engage
//
//  Created by Angela Smith on 7/21/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "DetailStoryHeaderView.h"
#import "DetailStoryMediaView.h"

@interface StoryDetailsInfoHeaderView : UIView

@property (nonatomic, strong) PFObject* thisStory;
//@property (nonatomic, strong) DetailStoryHeaderView* headerView;
@property (nonatomic, strong) DetailStoryMediaView* mediaView;
@property (nonatomic) CGFloat* totalViewHeight;

-(id)initWithFrame:(CGRect)frame story:(PFObject*)story viewHeight:(CGFloat*)viewHeight;
+ (CGRect)rectForView:(CGFloat)height;
@end
