//
//  CustomAlertView.h
//  Engage
//
//  Created by Angela Smith on 2/23/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CustomAlertView : UIAlertView
@property (nonatomic, retain) PFObject* selectedStory;

@end
