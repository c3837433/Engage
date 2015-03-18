//
//  FollowFriendsViewController.h
//  Engage Your City
//
//  Created by Angela Smith on 3/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "FriendCell.h"

@interface FollowFriendsViewController : PFQueryTableViewController <UITableViewDelegate,FriendCellDelegate>


@property (nonatomic, strong) PFUser* followersForUser;
@property (nonatomic) BOOL getFollowers;


@end
