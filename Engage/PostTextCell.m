//
//  PostTextCell.m
//  EngageCells
//
//  Created by Angela Smith on 2/15/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "PostTextCell.h"
#import "Utility.h"
#import "Cache.h"

@implementation PostTextCell
@synthesize thisPost, thisPostAuthor, postAuthorNameButton, postAuthorGroupButton, postAuthorImage, postStoryLabel, postTimeStampLabel, postTitleLabel, postAuthorPicButton, backgroundView, likeButton, commentButton, delegate, likesCommentsButton, thisAuthorGroup;




-(void)setUpStory:(PFObject*)post {
    
    // GET THE STORY OBJECTS
    thisPost = post;
    thisPostAuthor = [thisPost objectForKey:aPostAuthor];
    thisAuthorGroup = [thisPost objectForKey:aPostAuthorGroup];
    
    // set background
    backgroundView.layer.cornerRadius = 8.0f;
    // Border
    [backgroundView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [backgroundView.layer setBorderWidth:0.3f];
    // Shadow
    [backgroundView.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [backgroundView.layer setShadowOpacity:0.8];
    [backgroundView.layer setShadowRadius:0.8];
    [backgroundView.layer setShadowOffset:CGSizeMake(0.8, 0.8)];
    
    
    // SET AUTHOR PICTURE
    thisPostAuthor = [thisPost objectForKey:aPostAuthor];
    [self.postAuthorPicButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    // Set name button properties and avatar image
    if ([thisPostAuthor objectForKey:aPostAuthorImage]) {
        // NSLog(@"The author HAS profile image");
        PFFile* imageFile = [thisPostAuthor objectForKey:aPostAuthorImage];
        if ([imageFile isDataAvailable]) {
            //[cell.image loadInBackground];
            postAuthorImage.file = imageFile;
            [postAuthorImage loadInBackground];
        } else {
            postAuthorImage.file = imageFile;
            [postAuthorImage loadInBackground];
        }
    } else {
        //  NSLog(@"The author has NO profile image");
        postAuthorImage.image = [UIImage imageNamed:@"placeholder"];
    }
    
    
    // SET AUTHOR NAME
    [postAuthorNameButton setTitle:[thisPostAuthor objectForKey:aPostAuthorName] forState:UIControlStateNormal];
    //NSLog(@"Users name = %@", [storyAuthor objectForKey:@"UsersFullName"] );
    [postAuthorNameButton setTitle:[thisPostAuthor objectForKey:aPostAuthorName] forState:UIControlStateHighlighted];
    [self.postAuthorNameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // SET LOCAL GROUP
    if ([thisPost objectForKey:aPostAuthorGroup]) {
        [thisAuthorGroup fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [postAuthorGroupButton setTitle:[thisAuthorGroup objectForKey:aPostAuthorGroupTitle] forState:UIControlStateNormal];
            [postAuthorGroupButton setTitle:[thisAuthorGroup objectForKey:aPostAuthorGroupTitle] forState:UIControlStateHighlighted];
        }];
    } else {
        self.postAuthorGroupButton.hidden = YES;
    }
    int likeCount = 0;
    int comentCount = 0;
    // see how many likes or comments this story has
    if ([thisPost objectForKey:@"Likes"]) {
        // get the likes
        likeCount = [[thisPost objectForKey:@"Likes"] intValue];
    }
    // see how many likes or comments this story has
    if ([thisPost objectForKey:@"Comments"]) {
        // get the comment count
        comentCount = [[thisPost objectForKey:@"Comments"] intValue];
    }

    NSString* activityButtonString = @"";
    if ((likeCount != 0) || (comentCount != 0)) {
        // get the button string
        activityButtonString = [self getButtonTitleForLikes:likeCount andComments:comentCount];
        // set the string to the button
        [likesCommentsButton setTitle:activityButtonString forState:UIControlStateNormal];
        [likesCommentsButton setTitle:activityButtonString forState:UIControlStateHighlighted];
    }
    
    
    
    // SET TIME STAMP
    NSDate* timeCreated = thisPost .createdAt;
    // Set the time interval
    Utility* utility = [[Utility alloc] init];
    NSString* timeStampString = [utility stringForTimeIntervalSinceCreated:timeCreated];
    postTimeStampLabel.text = timeStampString;
    
    // SET TITLE AND TEXT
    postTitleLabel.text = [thisPost objectForKey:aPostTitle];
    postStoryLabel.text = [thisPost  objectForKey:aPostText];
    // Add like action
    [self.optionsButton addTarget:self action:@selector(didTapOptionsButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.likeButton addTarget:self action:@selector(didTapLikeTextStoryButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.postAuthorGroupButton addTarget:self action:@selector(didTapHomeGroupButton:) forControlEvents:UIControlEventTouchUpInside];
}


-(NSString*)getButtonTitleForLikes:(int)likes andComments:(int)comments
{
    NSString* likeString = @"";
    // get the likes
    if (likes != 0) {
        likeString = (likes == 1) ? @"1 Like" : [NSString stringWithFormat:@"%d Likes",likes];
    }
    NSString* commentString = @"";
    // get the comments
    if (comments != 0) {
        commentString = (comments == 1) ? @"1 Comment" : [NSString stringWithFormat:@"%d Comments",comments];
    }
    return [NSString stringWithFormat:@"%@ %@", likeString, commentString];
}


- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(postTextCell:didTapUserButton:user:)]) {
        [delegate postTextCell:self didTapUserButton:sender user:self.thisPostAuthor];
    }
}

- (void)didTapLikeTextStoryButton:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(postTextCell:didTapLikeTextStoryButton:story:)]) {
        [delegate postTextCell:self didTapLikeTextStoryButton:button story:self.thisPost];
    }
}

- (void)didTapHomeGroupButton:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(postTextCell:didTapHomeGroupButton:group:)]) {
        [delegate postTextCell:self didTapHomeGroupButton:button group:self.thisAuthorGroup];
    }
}

- (void)didTapOptionsButton:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(postTextCell:didTapOptionsButton:story:)]) {
        [delegate postTextCell:self didTapOptionsButton:button story:self.thisPost];
    }
}

- (void)setLikeStatus:(BOOL)liked
{
    [self.likeButton setSelected:liked];
    if (liked)
    {
        [self.likeButton setImage:[UIImage imageNamed:@"liked"] forState:UIControlStateSelected];
        [self.likeButton setImage:[UIImage imageNamed:@"liked"] forState:UIControlStateNormal];
        [self.likeButton setTitleColor:[UIColor colorWithRed:0.02 green:0.4 blue:0.56 alpha:1] forState:UIControlStateNormal];
        [self.likeButton setTitleColor:[UIColor colorWithRed:0.02 green:0.4 blue:0.56 alpha:1] forState:UIControlStateSelected];
    }
    else
    {
        [self.likeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.likeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];
    }
}

- (void)shouldEnableLikeButton:(BOOL)enable {
    if (enable) {
        [self.likeButton removeTarget:self action:@selector(didTapLikeTextStoryButton:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeButton addTarget:self action:@selector(didTapLikeTextStoryButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}


/*
- (void)shouldEnableLikeButton:(BOOL)enable
{
    likeButton.enabled = enable;
}*/
@end
