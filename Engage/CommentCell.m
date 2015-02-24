//
//  CommentCell.m
//  Engage
//
//  Created by Angela Smith on 7/18/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "CommentCell.h"
#import "Utility.h"
#import "ApplicationKeys.h"

@implementation CommentCell
@synthesize commentAuthorButton, commentAuthorPic, commentAuthorPicButton, commentText, commentTime, delegate, thisCommentUser;

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
    thisCommentUser = [story objectForKey:@"fromUser"];
    // Set Author and text
    
    // SET AUTHOR PICTURE
    [self.commentAuthorPicButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Set name button properties and avatar image
    if ([thisCommentUser objectForKey:aUserImage]) {
        // NSLog(@"The author HAS profile image");
        PFFile* imageFile = [thisCommentUser objectForKey:aUserImage];
        if ([imageFile isDataAvailable]) {
            //[cell.image loadInBackground];
            commentAuthorPic.file = imageFile;
            [commentAuthorPic loadInBackground];
        } else {
            commentAuthorPic.file = imageFile;
            [commentAuthorPic loadInBackground];
        }
    } else {
        //  NSLog(@"The author has NO profile image");
        commentAuthorPic.image = [UIImage imageNamed:@"placeholder"];
    }
    
    
    // SET AUTHOR NAME
    [commentAuthorButton setTitle:[thisCommentUser objectForKey:aUserName] forState:UIControlStateNormal];
    //NSLog(@"Users name = %@", [storyAuthor objectForKey:@"UsersFullName"] );
    [commentAuthorButton setTitle:[thisCommentUser objectForKey:aUserName] forState:UIControlStateHighlighted];
    [commentAuthorButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    commentText.text = [story objectForKey:@"message"];
    // Set Image
    PFFile *profilePictureSmall = [thisCommentUser objectForKey:@"profilePictureSmall"];
    commentAuthorPic.file = profilePictureSmall;
    [commentAuthorPic loadInBackground];
    // Set Date
    NSDate*  whenCreated = story.createdAt;
    Utility* utility = [[Utility alloc] init];
    NSString* timestamp = [utility stringForTimeIntervalSinceCreated:whenCreated];
    commentTime.text = timestamp;

}


- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(detailCommentCell:didTapUserButton:user:)]) {
        [delegate detailCommentCell:self didTapUserButton:sender user:thisCommentUser];
    }
}
@end
