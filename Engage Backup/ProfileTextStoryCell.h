//
//  ProfileTextStoryCell.h
//  Engage
//
//  Created by Angela Smith on 8/15/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>

@interface ProfileTextStoryCell : PFTableViewCell
{
    IBOutlet UIImageView* moreTextImage;
}
@property (nonatomic, strong) IBOutlet UILabel* storyTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel* storyTextLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeStampSinceCreationLabel;

-(void)setProfileTextStory:(PFObject*)story;
@end
