//
//  ProfileMediaStoryCell.h
//  Engage

//
//  Created by Angela Smith on 8/15/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>

@interface ProfileMediaStoryCell : PFTableViewCell

{
    IBOutlet UIImageView* moreTextImage;
}
@property (nonatomic, strong) IBOutlet UILabel* storyTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeStampSinceCreationLabel;
@property (nonatomic, strong) IBOutlet UILabel* storyTextLabel;
@property (nonatomic, strong) IBOutlet PFImageView* storyThumb;

-(void)setProfileMediaStory:(PFObject*)story;
@end
