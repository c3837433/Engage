//
//  DetailStoryMediaView.m
//  Engage
//
//  Created by Angela Smith on 7/21/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "DetailStoryMediaView.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation DetailStoryMediaView

@synthesize storyImage, mediaImageFile, mediaType, videoFile, playMovieButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setDetailStoryMedia:(PFObject*)story
{

    mediaType = [story objectForKey:@"media"];
    if ([mediaType isEqualToString:@"photo"])
    {
        mediaImageFile = [story objectForKey:@"uploadedMedia"];
        //playButton.image = nil;
        playMovieButton.hidden = YES;
        
    }
    else if ([mediaType isEqualToString:@"video"])
    {
        mediaImageFile = [story objectForKey:@"videoThumb"];
        //playButton.image = [UIImage imageNamed:@"play.png"];
        UIImage* buttonImage = [UIImage imageNamed:@"play.png"];
        [playMovieButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    }
    
    storyImage.file = mediaImageFile;
    [storyImage loadInBackground];
    
    
}
+ (id)detailMediaView
{
    DetailStoryMediaView* detailMediaView = [[[NSBundle mainBundle] loadNibNamed:@"StoryMediaView" owner:self options:nil] lastObject];
    
    // Make sure it is right view
    if ([detailMediaView isKindOfClass:[DetailStoryMediaView class]])
        return detailMediaView;
    else
        return nil;
}

@end
