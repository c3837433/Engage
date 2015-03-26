//
//  LocalGroupCell.h
//  Engage Your City
//
//  Created by Angela Smith on 3/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface LocalGroupCell : PFTableViewCell


@property (nonatomic, strong) IBOutlet UILabel* groupLeaderLabel;
@property (nonatomic, strong) IBOutlet UILabel* groupLocationLabel;
@property (nonatomic, strong) IBOutlet UILabel* groupDistanceLabel;
@property (nonatomic, strong) IBOutlet UILabel* groupMeetLabel;
@property (nonatomic, strong) IBOutlet UILabel* listNumberLabel;

@property (nonatomic, strong) PFObject* thisGroup;
-(void) setUpGroup:(PFObject*)group;
@end
