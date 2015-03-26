//
//  AdminSearchTableViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 3/25/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "AdminSearchTableViewController.h"
#import "ApplicationKeys.h"
#import "CustomAdminCreateViewController.h"

@interface AdminSearchTableViewController ()

@end

@implementation AdminSearchTableViewController

// Storyboard init
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithStyle:UITableViewStylePlain];
    self = [super initWithClassName:@"_User"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = @"_User";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of user stories to show per page
        self.objectsPerPage = 15;
    }
    return self;
}

// Search parse for Stories to be displayed withing the table
- (PFQuery *)queryForTable {
    // If this is not the current user, do not return anythign
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if (![PFUser currentUser])
    {
        [query setLimit:0];
        return query;
    }
    // Find any matching users 
    [query whereKey:aUserName containsString:self.nameSearch];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    }
    return query;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.objects.count) {
        UITableViewCell* cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nameCell" forIndexPath:indexPath];
        PFUser* user = (PFUser* )self.objects[indexPath.row];
        if (cell != nil) {
            cell.textLabel.text = [user objectForKey:aUserName];
        }
        return cell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    // Get and return the load more cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender{
   // Custom *vca = (ViewControllerA *)segue.destinationViewController;
    NSIndexPath *selectedPath = [self.tableView indexPathForCell:sender];
    PFUser* user = (PFUser* )self.objects[selectedPath.row];
    NSLog(@"The user selected: %@", [user objectForKey:aUserName]);
    self.selectedUser = user;
}



@end
