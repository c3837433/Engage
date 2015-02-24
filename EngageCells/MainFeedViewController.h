//
//  MainFeedViewController.h
//  EngageCells
//
//  Created by Angela Smith on 1/29/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import "StoryMediaCell.h"
#import "StoryTextCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <ParseUI/ParseUI.h>


@interface MainFeedViewController : PFQueryTableViewController <PFLogInViewControllerDelegate, TextStoryFooterDelegate, MediaStoryFooterDelegate>

@property (nonatomic, strong) NSMutableDictionary* activityQueries;


@end

