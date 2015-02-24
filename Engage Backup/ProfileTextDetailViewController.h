//
//  ProfileTextDetailViewController.h
//  Engage
//
//  Created by Angela Smith on 8/16/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileTextDetailViewController : UIViewController

{
    IBOutlet UILabel* storyTitleLabel;
    IBOutlet UILabel* storyTextLabel;
    IBOutlet UILabel* timeStampSinceCreationLabel;
    IBOutlet UIView* storyView;
}

@property (nonatomic, strong) PFObject* selectedObject;

@end
