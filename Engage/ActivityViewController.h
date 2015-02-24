//
//  ActivityViewController.h
//  Engage
//
//  Created by Angela Smith on 1/22/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import "ActivityCell.h"

@interface ActivityViewController : PFQueryTableViewController <ActivityCellDelegate>

+ (NSString *)stringForActivityType:(NSString *)activityType;

@end