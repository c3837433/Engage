//
//  StoryDetailsInfoHeaderView.m
//  Engage
//
//  Created by Angela Smith on 7/21/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "StoryDetailsInfoHeaderView.h"
#import "AddStoryCommentViewController.h"

@implementation StoryDetailsInfoHeaderView
@synthesize thisStory, mediaView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame story:(PFObject*)story viewHeight:(CGFloat*)viewHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        thisStory = story;

    }
    self.backgroundColor = [UIColor clearColor];

    return self;
}

+ (CGRect)rectForView:(CGFloat)height {
    
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, height);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
