//
//  ProfileStoryDetailViewController.m
//  Engage
//
//  Created by Angela Smith on 8/15/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "ProfileStoryDetailViewController.h"
#import "Utility.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ProfileStoryDetailViewController ()

@end

@implementation ProfileStoryDetailViewController
@synthesize selectedObject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // Add background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBg"]];
    // Hide the play button unless it is needed
    playMovieButton.hidden = YES;
    // set this story details to the view
    storyTitleLabel.text = [selectedObject objectForKey:@"title"];
    storyTextLabel.text = [selectedObject objectForKey:@"story"];
    if ([selectedObject objectForKey:@"mediaThumb"] != nil)
    {
        PFFile* imageFile = [selectedObject objectForKey:@"mediaThumb"];
        mediaImage.file = imageFile;
        [mediaImage loadInBackground];
    }
    if ([[selectedObject objectForKey:@"media"] isEqualToString:@"video"])
    {
        // Add the play button
        playMovieButton.hidden = NO;
    }
    // Finally, set the time string based on creation time
    NSDate* storyCreatedAt = selectedObject.createdAt;
    // Find the time inverval and format it
    //NSTimeInterval timeInterval = [storyCreatedAt timeIntervalSinceNow];
    //TTTTimeIntervalFormatter* timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
    // Get that time string and set to the label
    //NSString* timeString = [timeFormatter stringForTimeInterval:timeInterval];
    Utility* utility = [[Utility alloc] init];
    NSString* timestamp = [utility stringForTimeIntervalSinceCreated:storyCreatedAt];
    timeStampSinceCreationLabel.text = timestamp;
    //timeStampSinceCreationLabel.text = timeString;
    
    // Add view border, shadow, and corners
    // Corners & Border
    storyDetailView.layer.cornerRadius = 8.0f;
    [storyDetailView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [storyDetailView.layer setBorderWidth:0.3f];
    // Shadow
    [storyDetailView.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [storyDetailView.layer setShadowOpacity:0.8];
    [storyDetailView.layer setShadowRadius:0.8];
    [storyDetailView.layer setShadowOffset:CGSizeMake(0.8, 0.8)];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(IBAction)playStoryVideo:(UIButton*)button
{
    // Get the video file
    PFFile* movieFile = [selectedObject objectForKey:@"uploadedMedia"];
    // and it's url
    NSString* movieUrl = movieFile.url;
    // Prepare the movie player controller with the video
    MPMoviePlayerViewController* moviePlayerControl = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:movieUrl]];
    // Make the video full screen
    moviePlayerControl.moviePlayer.fullscreen=TRUE;
    // Show the movie and begin playing
    [self presentMoviePlayerViewControllerAnimated:moviePlayerControl];
    [moviePlayerControl.moviePlayer play];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
