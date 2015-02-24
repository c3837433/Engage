//
//  HomeGroupTableViewCell.m
//  Engage
//
//  Created by Angela Smith on 7/14/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "HomeGroupTableViewCell.h"

@implementation HomeGroupTableViewCell
@synthesize groupLeaders, groupLocation, groupMeeting;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)refreshGroupList:(NSString*)location leader:(NSString*)leader meets:(NSString*)meets
{
    groupMeeting.text = meets;
    groupLocation.text = location;
    groupLeaders.text = leader;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
