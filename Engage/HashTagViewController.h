//
//  HashTagViewController.h
//  Engage
//
//  Created by Angela Smith on 2/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "PostTextCell.h"

@interface HashTagViewController : PFQueryTableViewController <PostTextCellDelegate>


@property (nonatomic, strong) NSMutableDictionary* activityQueries;
@property (nonatomic, strong) NSString* seletedHashtag;
@end
