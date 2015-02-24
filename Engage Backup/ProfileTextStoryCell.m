//
//  ProfileTextStoryCell.m
//  Engage
//
//  Created by Angela Smith on 8/15/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "ProfileTextStoryCell.h"
#import "Utility.h"

@implementation ProfileTextStoryCell
@synthesize storyTextLabel, storyTitleLabel, timeStampSinceCreationLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setProfileTextStory:(PFObject*)story
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

    // SET TEXT LABELS
    NSString* textString = [story objectForKey:@"story"];
    storyTitleLabel.text = [story objectForKey:@"title"];
    storyTextLabel.text = textString;
    
    // calculate to see if the text will need the more button
    BOOL needsMoreButton = [self needMoreButtonforTextLabel:storyTextLabel];
    // Set the button to be hidden or not based on whether it is needed
    moreTextImage.hidden = (needsMoreButton) ? NO : YES;

}

- (BOOL)needMoreButtonforTextLabel:(UILabel*)textLabel
{
    // Set the constraint of the story text label
    CGSize constraint = CGSizeMake(textLabel.bounds.size.width, CGFLOAT_MAX);
    // Determine the size needed based on the story label font
    NSDictionary* labelFontSize = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica Neue" size:14.0f] forKey:NSFontAttributeName];
    // Determine how big the label would need to be for this text label
    CGSize textSize = [textLabel.text boundingRectWithSize: constraint options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes: labelFontSize context: nil].size;
    // If this label frame is less than the height required for the label
    if (self.frame.size.height < ceilf(textSize.height))
    {
        // We need the more button
        //NSLog(@"This label needs a button.");
        return YES;
    }
    // Otherwise, it is not needed
     //NSLog(@"This label does not need a button because it fits.");
    return NO;
}

@end
