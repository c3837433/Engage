//
//  FollowFriendsViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 3/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "FollowFriendsViewController.h"
#import "ApplicationKeys.h"

@interface FollowFriendsViewController ()

@end

@implementation FollowFriendsViewController


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"_User"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.parseClassName = @"_User";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of objects to show per page
        self.objectsPerPage = 7;
    }
    return self;
}


#pragma mark - PFQueryTableViewController
- (PFQuery *)queryForTable {
    PFQuery* userQuery = [PFUser query];
    // If this is not the current user, do not return anythign
    NSMutableArray* followers = [[NSMutableArray alloc] init];
    PFQuery *followeesQuery = [PFQuery queryWithClassName:aActivityClass];
    NSString* followKey = (self.getFollowers) ? aActivityFromUser : aActivityToUser;
    NSString* reverseFollow = (self.getFollowers) ? aActivityToUser : aActivityFromUser;
    // find objects where the toUer/fromUser = this user
    NSLog(@"This user: %@", self.followersForUser);
    [followeesQuery whereKey:followKey equalTo:self.followersForUser];
    [followeesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Found followers: %@", objects.description);
        [followers removeAllObjects];
        for (PFObject* activity in objects) {
            PFUser* user = [activity objectForKey:reverseFollow];
            [followers addObject:user.objectId];
        }

        [userQuery whereKey:@"objectId" containedIn:followers];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"Objects found:  %lu, %@", (unsigned long)objects.count, objects.description);
        }];
    }];

    return userQuery;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    NSLog(@"Users returned %lu", (unsigned long)self.objects.count);
    NSLog(@"This follower: %@", [object objectForKey:@"UsersFullName"]);
    static NSString *FriendCellIdentifier = @"followFriendCell";
    FriendCell* cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell != nil) {
        cell.delegate = self;
        [cell setUser:(PFUser*)object];
        cell.followButton.tag = indexPath.row;
        // Set the default stories
        // get the people the user already follows
        
        cell.followButton.selected = NO;
        cell.followButton.tag = indexPath.row;
        cell.tag = indexPath.row;
    }
    return cell;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // get the activity class
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
