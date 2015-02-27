//
//  ProfileTextStoryCell.h
//  Engage
//
//  Created by Angela Smith on 8/15/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import "STTweetLabel.h"
#import <ParseUI/ParseUI.h>

@interface ProfileTextStoryCell : PFTableViewCell
{
    IBOutlet UIImageView* moreTextImage;
}
@property (nonatomic, strong) IBOutlet UILabel* storyTitleLabel;
@property (nonatomic, strong) IBOutlet STTweetLabel* storyTextLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeStampSinceCreationLabel;
@property (nonatomic, strong) PFObject* profileStory;
-(void)setProfileTextStory:(PFObject*)story;
@end
