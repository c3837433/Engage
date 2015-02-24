//
//  StoryTextCell.m
//  Engage
//
//  Created by Angela Smith on 8/15/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "StoryTextCell.h"
#import "Utility.h"

@implementation StoryTextCell
@synthesize authorPic, storyAuthorLabel, storyTextLabel, storyTitleLabel, timeStampSinceCreationLabel, backgroundView, homeGroupLabel, likeButton, commentButton, delegate, thisStory;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setTextStory:(PFObject*)story
{
    PFUser* user = [story objectForKey:@"author"];
    PFFile* authorPict = [user objectForKey:@"profilePictureSmall"];
    
    // GET TIME STAMP
    NSDate* timeCreated = story.createdAt;
    // Set the time interval
    Utility* utility = [[Utility alloc] init];
    NSString* timeStampString = [utility stringForTimeIntervalSinceCreated:timeCreated];
    
    
    // SET THE BACKGROUND ACCENTS
    backgroundView.layer.cornerRadius = 8.0f;
    // border
    [backgroundView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [backgroundView.layer setBorderWidth:0.3f];
    // Shadow
    [backgroundView.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [backgroundView.layer setShadowOpacity:0.8];
    [backgroundView.layer setShadowRadius:0.8];
    [backgroundView.layer setShadowOffset:CGSizeMake(0.8, 0.8)];
    
    

    
    // SET TEXT LABELS
    storyAuthorLabel.text = [user objectForKey:@"UsersFullName"];
    storyTitleLabel.text = [story objectForKey:@"title"];
    storyTextLabel.text = [story objectForKey:@"story"];
    
    
    if ([story objectForKey:@"Group"]) {
        PFObject* group = [story objectForKey:@"Group"];
        [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [homeGroupLabel setTitle:[group objectForKey:@"groupHeader"] forState:UIControlStateNormal];
            [homeGroupLabel setTitle:[group objectForKey:@"groupHeader"] forState:UIControlStateHighlighted];
            //homeGroupLabel.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
            [homeGroupLabel sizeToFit];
        }];
    }
    
    // SET THE USER PICTURE
    // add, load the pic, round the imageview corners and hid the corner
    authorPic.layer.cornerRadius = 8;
    authorPic.file = authorPict;
    [authorPic loadInBackground];
    authorPic.clipsToBounds = YES;
    
    
    // SET TIMESTAMP
    timeStampSinceCreationLabel.text = timeStampString;
    
    // Add like action
    [self.likeButton addTarget:self action:@selector(didTapLikeStoryButton:) forControlEvents:UIControlEventTouchUpInside];

}


-(void)story:(PFObject*)story
{
    self.thisStory = story;
    [likeButton addTarget:self action:@selector(didTapLikeStoryButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)didTapLikeStoryButton:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(storyActionFooter:didTapTextLikeStoryButton:story:)]) {
        [delegate storyActionFooter:self didTapTextLikeStoryButton:button story:self.thisStory];
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
     
     
    //[self.likeButton setSelected:liked];
   // self.likeButton.imageView.image = (liked) ? [UIImage imageNamed:@"liked"] : [UIImage imageNamed:@"like"];
   // self.likeButton.titleLabel.tintColor = (liked) ? [UIColor colorWithRed:0.02 green:0.4 blue:0.56 alpha:1] : [UIColor darkGrayColor];
}


- (void)shouldEnableLikeButton:(BOOL)enable
{
    likeButton.enabled = enable;
}


@end
