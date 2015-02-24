//
//  CommentCell.m
//  Engage
//
//  Created by Angela Smith on 7/18/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "CommentCell.h"
#import "Utility.h"

@implementation CommentCell
@synthesize commentAuthor, commentAuthorPic, commentText, commentTime;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setComment:(PFObject*)story
{
    PFUser *user = [story objectForKey:@"fromUser"];
    // Set Author and text    
    commentAuthor.text = [user objectForKey:@"UserProfileName"];
    commentText.text = [story objectForKey:@"commentText"];
    // Set Image
    PFFile *profilePictureSmall = [user objectForKey:@"profilePictureSmall"];
    commentAuthorPic.file = profilePictureSmall;
    [commentAuthorPic loadInBackground];
    // Set Date
    NSDate*  whenCreated = story.createdAt;
    //NSTimeInterval timeInterval = [whenCreated timeIntervalSinceNow];
    //TTTTimeIntervalFormatter* thisInterval = [[TTTTimeIntervalFormatter alloc] init];
    //NSString *timestamp = [thisInterval stringForTimeInterval:timeInterval];
    Utility* utility = [[Utility alloc] init];
    NSString* timestamp = [utility stringForTimeIntervalSinceCreated:whenCreated];
    commentTime.text = timestamp;

}
@end
