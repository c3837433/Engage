//
//  MainFeedViewController.h
//  Engage
//
//  Created by Angela Smith on 8/16/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import "StoryMediaCell.h"
#import "StoryTextCell.h"
#import "TTTTimeIntervalFormatter.h"
#import <MediaPlayer/MediaPlayer.h>


@interface MainFeedViewController : PFQueryTableViewController <PFLogInViewControllerDelegate, UIActionSheetDelegate, TextStoryFooterDelegate, MediaStoryFooterDelegate>

@property (nonatomic, strong) NSMutableDictionary* activityQueries;


@end
