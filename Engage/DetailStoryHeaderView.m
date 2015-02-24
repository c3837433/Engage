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

@synthesize storyAuthor, storyAuthorPic, storyTime, storyGroup, storyTitle, userButton, storyAuthorButton, storyGroupButton, textLabel;

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
    PFUser *user = [story objectForKey:aPostAuthor];
    // Set Author and title
    [storyAuthorButton setTitle:[user objectForKey:aPostAuthorName] forState:UIControlStateNormal];
    //NSLog(@"Users name = %@", [storyAuthor objectForKey:@"UsersFullName"] );
    [storyAuthorButton setTitle:[user objectForKey:aPostAuthorName] forState:UIControlStateHighlighted];
    
    // Set group
    PFObject* group = [story objectForKey:aPostAuthorGroup];
    //storyGroup.text = [group objectForKey:@"groupHeader"];
    [storyGroupButton setTitle:[group objectForKey:aPostAuthorGroupTitle] forState:UIControlStateNormal];
    //NSLog(@"Users name = %@", [storyAuthor objectForKey:@"UsersFullName"] );
    [storyGroupButton setTitle:[group objectForKey:aPostAuthorGroupTitle] forState:UIControlStateHighlighted];
    //storyAuthor.text = [user objectForKey:@"UsersFullName"];
    storyTitle.text = [story objectForKey:aPostTitle];
   // textLabel.text = [story objectForKey:@"story"];
    // set profile image
    // Set name button properties and avatar image
    if ([user objectForKey:aPostAuthorImage]) {
        // NSLog(@"The author HAS profile image");
        PFFile* imageFile = [user objectForKey:aPostAuthorImage];
        if ([imageFile isDataAvailable]) {
            //[cell.image loadInBackground];
            storyAuthorPic.file = imageFile;
            [storyAuthorPic loadInBackground];
        } else {
            storyAuthorPic.file = imageFile;
            [storyAuthorPic loadInBackground];
        }
    } else {
        //  NSLog(@"The author has NO profile image");
        storyAuthorPic.image = [UIImage imageNamed:@"placeholder"];
    }
    

    // Set Date
    NSDate*  whenCreated = story.createdAt;
    //NSTimeInterval timeInterval = [whenCreated timeIntervalSinceNow];
    //TTTTimeIntervalFormatter* thisInterval = [[TTTTimeIntervalFormatter alloc] init];
    //NSString *timestamp = [thisInterval stringForTimeInterval:timeInterval];
    Utility* utility = [[Utility alloc] init];
    NSString* timestamp = [utility stringForTimeIntervalSinceCreated:whenCreated];
    storyTime.text = timestamp;
    
   // [self.superview setFrame:CGRectMake(0, 0, textLabel.frame.size.width. + 20, textLabel.frame.size.height  + 100)];
   // [textLabel.superview setFrame: CGFrameMake(0, 0, textLabel.frame.size.width + 2* textLabel.frame.origin.x, textLabel.frame.size.height + 108)];
    //[self.textLabel setAutoresizesSubviews:YES];
    //[self.textLabel setAutoresizingMask:
    // UIViewAutoresizingFlexibleWidth];
    
   // [self.superview setAutoresizesSubviews:YES];
    //[self.superview setAutoresizingMask:
    // UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
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
