//
//  ActivityCell.h
//  Engage Your City
//
//  Created by Angela Smith on 2/27/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "MZSelectableLabel.h"
#import <Parse/Parse.h>

@interface ActivityCell : PFTableViewCell


@property (nonatomic, strong) IBOutlet MZSelectableLabel* activityLabel;
@property (nonatomic, strong) IBOutlet PFImageView* profileImageView;
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;
@property (nonatomic, strong) PFObject* thisActivity;


//@property (nonatomic, strong) PFObject* thisActivity;
-(void)setActivity:(PFObject*) activity;
@end
