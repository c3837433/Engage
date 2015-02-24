//
//  ProfileMediaStoryCell.m
//  Engage
//
//  Created by Angela Smith on 8/15/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "ProfileMediaStoryCell.h"
#import "Utility.h"

@implementation ProfileMediaStoryCell
@synthesize timeStampSinceCreationLabel, storyTitleLabel, storyTextLabel, storyThumb;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setProfileMediaStory:(PFObject*)story
{
    // GET AND SET THE TIME STAMP
    NSDate* timeCreated = story.createdAt;
    // Set the time interval
    //NSTimeInterval timeInterval = [timeCreated timeIntervalSinceNow];
    //TTTTimeIntervalFormatter* timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
    //NSString* timeStampString = [timeFormatter stringForTimeInterval:timeInterval];
    Utility* utility = [[Utility alloc] init];
    NSString* timestamp = [utility stringForTimeIntervalSinceCreated:timeCreated];
    timeStampSinceCreationLabel.text = timestamp;
    
    // GET AND SET THE MEDIA
    PFFile* storyMedia = [story objectForKey:@"mediaThumb"];
    storyThumb.file = storyMedia;
    storyThumb.layer.cornerRadius = 8;
    [storyThumb loadInBackground];
    
    // SET TEXT LABELS
    NSString* textString = [story objectForKey:@"story"];
    storyTitleLabel.text = [story objectForKey:@"title"];
    storyTextLabel.text = textString;
    
    // see if this cell is trunctated
    BOOL needsMoreButton = [self needMoreButtonforTextLabel:storyTextLabel];
    // if the button is not needed, hide it
    moreTextImage.hidden = (needsMoreButton) ? NO : YES;
}

- (BOOL)needMoreButtonforTextLabel:(UILabel*)textLabel
{
    // Set the constraint of the story text label
    CGSize constraint = CGSizeMake(textLabel.bounds.size.width, CGFLOAT_MAX);
    // Determine the size needed based on the story label font
    NSDictionary* labelFontSize = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica Neue" size:14.0f] forKey:NSFontAttributeName];
    // Determine how big the label would need to be for this text string with both length and height
    CGSize textSize = [textLabel.text boundingRectWithSize: constraint options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes: labelFontSize context: nil].size;
    // If this label frame is less than the height required for the label
    if (self.frame.size.height < ceilf(textSize.height))
    {
        // We need the more button
        return YES;
    }
    // Otherwise, it is not needed
    return NO;
}


@end
