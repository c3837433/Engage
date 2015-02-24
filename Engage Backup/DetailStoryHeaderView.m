//
//  DetailStoryHeaderView.m
//  Engage
//
//  Created by Angela Smith on 7/21/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "DetailStoryHeaderView.h"
#import "Utility.h"

@implementation DetailStoryHeaderView

@synthesize storyAuthor, storyAuthorPic, storyTime, storyGroup, storyTitle, userButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setDetailHeaderInfo:(PFObject*)story
{
    PFUser *user = [story objectForKey:@"author"];
    // Set Author and title
    storyAuthor.text = [user objectForKey:@"UserProfileName"];
    storyTitle.text = [story objectForKey:@"title"];
    // Set group
    PFObject* group = [story objectForKey:@"Group"];
    storyGroup.text = [group objectForKey:@"groupHeader"];
    // set profile image
    PFFile *profilePictureSmall = [user objectForKey:@"profilePictureSmall"];
    storyAuthorPic.file = profilePictureSmall;
    [storyAuthorPic loadInBackground];
    // Set Date
    NSDate*  whenCreated = story.createdAt;
    //NSTimeInterval timeInterval = [whenCreated timeIntervalSinceNow];
    //TTTTimeIntervalFormatter* thisInterval = [[TTTTimeIntervalFormatter alloc] init];
    //NSString *timestamp = [thisInterval stringForTimeInterval:timeInterval];
    Utility* utility = [[Utility alloc] init];
    NSString* timestamp = [utility stringForTimeIntervalSinceCreated:whenCreated];
    storyTime.text = timestamp;
    
}

+ (id)detailHeaderView
{
    DetailStoryHeaderView* detailHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"StoryDetailHeader" owner:self options:nil] lastObject];
    
    // Make sure it is right
    if ([detailHeaderView isKindOfClass:[DetailStoryHeaderView class]])
        return detailHeaderView;
    else
        return nil;
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
