//
//  LocalFeedViewController.h
//  Engage
//
//  Created by Angela Smith on 1/22/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import "StoryMediaCell.h"
#import "StoryTextCell.h"
#import "TTTTimeIntervalFormatter.h"
#import <MediaPlayer/MediaPlayer.h>


@interface LocalFeedViewController : PFQueryTableViewController <PFLogInViewControllerDelegate, UIActionSheetDelegate, TextStoryFooterDelegate, MediaStoryFooterDelegate>

@property (nonatomic, strong) NSMutableDictionary* activityQueries;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* actionButton;
@end
