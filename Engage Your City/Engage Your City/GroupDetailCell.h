//
//  GroupDetailCell.h
//  Engage Your City
//
//  Created by Angela Smith on 3/23/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface GroupDetailCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* infoTitleLabel;
@property (nonatomic, strong) IBOutlet UITextView* infoDescriptionLabel;
@property (nonatomic, strong) IBOutlet UIImageView* infoIconImage;

@end
