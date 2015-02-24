//
//  ProfileStoryDetailViewController.h
//  Engage
//
//  Created by Angela Smith on 8/15/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileStoryDetailViewController : UIViewController

{
    IBOutlet UILabel* storyTitleLabel;
    IBOutlet UILabel* storyTextLabel;
    IBOutlet UILabel* timeStampSinceCreationLabel;
    IBOutlet PFImageView* mediaImage;
    IBOutlet UIButton* playMovieButton;
    IBOutlet UIView* storyDetailView;
}

@property (nonatomic, strong) PFObject* selectedObject;

@end
