//
//  GroupDetailViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 3/18/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "GroupDetails.h"
#import "ApplicationKeys.h"
#import "GroupDetailCell.h"
#import "Utility.h"
#import "Cache.h"

@interface GroupDetailViewController () {
    
    NSMutableArray* groupDetailList;
}
@end

@implementation GroupDetailViewController

- (void)viewDidLoad
{
    // Get details for this group
    groupDetailList = [[NSMutableArray alloc] init];
    [self.group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            self.group = object;
            [self setUpTableWithGroupDetails:object];
        }
    }];
    self.detailsTable.estimatedRowHeight = 108;
    self.detailsTable.rowHeight = UITableViewAutomaticDimension;
    [super viewDidLoad];
}

-(void) setUpTableWithGroupDetails:(PFObject*) group {
    // SET UP HEADER VIEW
    [self setUpFollowersAndMembers];
    //and leaders name & about me info
    self.groupLeaderNameLabel.text = [self.group objectForKey:aHomeGroupLeader];
    self.groupAboutUsLabel.text = [self.group objectForKey:aHomeGroupAbout];
    NSArray* groupLeaders = [self.group objectForKey:aHomegroupLeadersArray];
    NSLog(@"%lu Leaders for group: %@", (unsigned long)groupLeaders.count, groupLeaders.description);
    switch (groupLeaders.count) {
        case 0:
            NSLog(@"there are no leaders for this group");
            break;
        case 1:
            NSLog(@"there is one leaders for this group");
            break;
        case 2:
            NSLog(@"there are two leaders for this group");
            break;
        default:
            NSLog(@"There are more than two leaders for this group");
            break;
    }
    
    // GET GROUP DETAILS FOR TABLEVIEW
    // location
    if ([group objectForKey:aHomeGroupLocation]) {
        GroupDetails* detail = [self createDetailWithTitle:@"Location" description:[group objectForKey:aHomeGroupLocation] andIcon:[UIImage imageNamed:@"location"]];
        [groupDetailList addObject:detail];
    }
    // social
    if ([group objectForKeyedSubscript:aHomeGroupLinks]) {
        NSArray* socialLinks = [group objectForKey:aHomeGroupLinks];
        NSString* arrayString = [socialLinks componentsJoinedByString:@"\n"];
        GroupDetails * detail = [self createDetailWithTitle:@"Social Links" description:arrayString andIcon:[UIImage imageNamed:@"social"]];
        [groupDetailList addObject:detail];
    }
    // meet
    if (([group objectForKey:aHomeGroupMeetDate]) || ([group objectForKey:aHomeGroupMeetTime])) {
        NSString* meetingDate = @"";
        NSString* meetingTime = @"";
        if ([group objectForKey:aHomeGroupMeetDate]) {
            meetingDate = [group objectForKey:aHomeGroupMeetDate];
        }
        if ([group objectForKey:aHomeGroupMeetTime]) {
            meetingTime = [group objectForKey:aHomeGroupMeetTime];
        }
        NSString* meetString = [NSString stringWithFormat:@"%@\n%@", meetingDate, meetingTime];
        GroupDetails * detail = [self createDetailWithTitle:@"Meets" description:meetString andIcon:[UIImage imageNamed:@"meet"]];
        [groupDetailList addObject:detail];
    }
    // contact
    if ([group objectForKey:aHomeGroupPhone]) {
        NSString* phone = [group objectForKey:aHomeGroupPhone];
        GroupDetails * detail = [self createDetailWithTitle:@"Contact" description:phone andIcon:[UIImage imageNamed:@"contact"]];
        [groupDetailList addObject:detail];
    }
    [self.detailsTable reloadData];
    // Get the buttons ready
    [self setUpFollowAndJoinButtons];
    
}

-(void) setUpFollowersAndMembers {
    int followerCount = 0;
    int memberCount = 0;
    // see how many likes or comments this story has
    if ([self.group objectForKey:@"Followers"]) {
        // get the likes
        followerCount = [[self.group objectForKey:@"Followers"] intValue];
    }
    // see how many likes or comments this story has
    if ([self.group objectForKey:@"Members"]) {
        // get the comment count
        memberCount = [[self.group objectForKey:@"Members"] intValue];
    }
    
    // get the button string
    NSString* followMemberString = [self getLabelStringForFollowersAndMembers:followerCount andMembers:memberCount];
    // set the string to the button
    self.groupFollowLabel.text = followMemberString;
}

-(void) setUpFollowAndJoinButtons {
    // Set up follow button
    NSDictionary *attributes = [[Cache sharedCache] attributesForUser:[PFUser currentUser]];
    if (attributes) {
        // set them accordingly
        [self.followButton setSelected:[[Cache sharedCache] followStatusForGroup:self.group]];
        [self.joinButton setSelected:[[Cache sharedCache] joinStatusForGroup:self.group]];
    } else {
        @synchronized(self) {
            PFQuery *isFollowingQuery = [PFQuery queryWithClassName:aActivityClass];
            [isFollowingQuery whereKey:aActivityFromUser equalTo:[PFUser currentUser]];
            [isFollowingQuery whereKey:aActivitytoGroup equalTo:self.group];
            [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
            [isFollowingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects) {
                    BOOL isFollowing = false;
                    BOOL isMember = false;
                    for (PFObject* activity in objects) {
                        if ([[activity objectForKey:aActivityType] isEqualToString:aActivityFollowGroup]) {
                            //NSLog(@"found following activity for group");
                            isFollowing = true;
                            break;
                        }
                        if ([[activity objectForKey:aActivityType] isEqualToString:aActivityJoinGroup]) {
                             //NSLog(@"found joined activity for group");
                            isMember = true;
                            break;
                        }
                    }
                    @synchronized(self) {
                        //NSLog(@"Setting cache");
                        [[Cache sharedCache] setFollowGroupStatus:isFollowing group:self.group];
                        [[Cache sharedCache] setJoinedGroupStatus:isMember group:self.group];
                    }
                    //NSLog(@"Setting buttons");
                    [self.followButton setSelected:isFollowing];
                    [self.joinButton setSelected:isMember];
                }
            }];
            [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                @synchronized(self) {
                    [[Cache sharedCache] setFollowGroupStatus:(!error && number > 0) group:self.group];
                }
                [self.followButton setSelected:(!error && number > 0)];
            }];
        }
    }
}


-(GroupDetails*) createDetailWithTitle:(NSString*)title description:(NSString*)description andIcon:(UIImage*)icon {
    GroupDetails* detail = [[GroupDetails alloc] init];
    detail.detailTitle = title;
    detail.detailDescription = description;
    detail.detailIcon = icon;
    return detail;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITABLEVIEW DELEGATE AND DATA SOURCE METHODS
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return groupDetailList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    if (cell != nil) {
        GroupDetails* thisGroup = [groupDetailList objectAtIndex:indexPath.row];
        cell.infoTitleLabel.text = thisGroup.detailTitle;
        cell.infoDescriptionLabel.text = thisGroup.detailDescription;
        cell.infoIconImage.image = thisGroup.detailIcon;
    }
    return cell;
}


-(void)viewWillAppear:(BOOL)animated {
    // Stop the view from making rows highlighted when returning from mapview
    NSIndexPath *indexPath = [self.detailsTable indexPathForSelectedRow];
    [self.detailsTable deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma  mark - BUTTON ACTIONS

-(IBAction)didTapFollowGroup:(UIButton*) button {
    NSLog(@"User wants to follow this group");
    if ([button isSelected]) {
        // Unfollow
        button.selected = NO;
        // remove group from user
        
        [Utility unfollowGroupEventually:self.group];
    }
    else {
        // Follow
        button.selected = YES;
        [Utility followGroupInBackground:self.group block:^(BOOL succeeded, NSError *error) {
            if (error) {
                button.selected = NO;
            } else {
                // Update the label
                [self setUpFollowersAndMembers];
            }
            
        }];
        
    }
}

-(IBAction)didTapJoinGroup:(UIButton*) button {

    // Is the button selected?
    if ([button isSelected]) {
        // unjoin
        button.selected = NO;
        [Utility leaveGroupEventually:self.group];
    } else {
        // See if the user already is part of another group
        //NSString* groupId = self.group.objectId;
        //NSLog(@"The current group: %@ with leaders %@", groupId, [self.group objectForKey:aHomeGroupLeader]);
        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
          //  NSLog(@"retrieved user info");
            PFObject* group = [[PFUser currentUser] objectForKey:aUserGroup];
            [group fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                NSString* currentId = group.objectId;
            //    NSLog(@"Retrieved user group: %@", currentId);
                if (![currentId isEqual:@""]) {
                    // User has a group alert them to make sure they want to change it
                    [self alertUserForChangeGroupConfirmation:group andSetButton:button];
                } else {
                    // Join this one
                    [self joinGroup:self.group andSetButton:button toSelected:YES];
                }
            }];
        }];
    }
}

-(void)joinGroup:(PFObject*)group andSetButton:(UIButton*)button toSelected:(BOOL)selected {
    button.selected = selected;
    [Utility joinGroupInBackground:group block:^(BOOL succeeded, NSError *error) {
        if (error) {
            button.selected = NO;
        } else {
            // Update the label
            [self setUpFollowersAndMembers];
        }
    }];
}

-(void)changeGroups:(PFObject*)fromGroup  toGroup:(PFObject*) toGroup andSetButton:(UIButton*)button toSelected:(BOOL)selected {
    button.selected = selected;
    [Utility changeGroupsInBackgroundFromOldGroup:fromGroup toNewGroup:toGroup block:^(BOOL succeeded, NSError *error) {
        if (error) {
            button.selected = NO;
            NSLog(@"Couldn't changed groups");
        } else {
            // Update the label
            NSLog(@"Successfully changed groups");
            [self setUpFollowersAndMembers];
        }

    }];
}

-(void) alertUserForChangeGroupConfirmation:(PFObject*)currentGroup andSetButton:(UIButton*)button {
    NSString* currentGroupLead = [currentGroup objectForKey:aHomeGroupLeader];
    NSString* thisGroupLeader = [self.group objectForKey:aHomeGroupLeader];
    NSString* message = [NSString stringWithFormat:@"Leave %@ and join %@ instead?", currentGroupLead, thisGroupLeader];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Group Already Set"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              [self changeGroups:currentGroup toGroup:self.group andSetButton:button toSelected:true];
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                          }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:defaultAction];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];


}

-(NSString*)getLabelStringForFollowersAndMembers:(int)followers andMembers:(int)members
{
    NSString* followerString = @"";
    // get the likes
    if (followers != 0) {
        followerString = (followers == 1) ? @"1 Follower" : [NSString stringWithFormat:@"%d Followers",followers];
    }
    NSString* memberString = @"";
    // get the comments
    if (members != 0) {
        memberString = (members == 1) ? @"1 Member" : [NSString stringWithFormat:@"%d Members",members];
    }
    return [NSString stringWithFormat:@"%@ %@", followerString, memberString];
}

@end
