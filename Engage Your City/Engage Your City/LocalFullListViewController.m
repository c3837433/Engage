//
//  LocalFullListViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 3/26/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "LocalFullListViewController.h"
#import "ApplicationKeys.h"
#import "AppDelegate.h"
#import "LocalGroupCell.h"
#import "GroupDetailViewController.h"

@interface LocalFullListViewController ()

@end

@implementation LocalFullListViewController

#pragma mark PARSE QUERY

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithStyle:UITableViewStyleGrouped];
    //self = [super initWithClassName:@"HomeGroups"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of user stories to show per page
        self.objectsPerPage = 10;
    }
    return self;
}


- (PFQuery *)queryForTable {
    PFQuery* query;
    if (self.searchList) {
        NSLog(@"User is searching for: %@", self.searchTerm);
        // get the search term to check
        PFQuery* locationQuery = [PFQuery queryWithClassName:@"HomeGroups"];
        [locationQuery  whereKey:aHomeGroupTitle containsString:self.searchTerm];
        
        PFQuery* timeQuery = [PFQuery queryWithClassName:@"HomeGroups"];
        [timeQuery whereKey:aHomeGroupMeetDate containsString:self.searchTerm];
        query = [PFQuery orQueryWithSubqueries:@[locationQuery,timeQuery]];
    } else {
        query = [PFQuery queryWithClassName:@"HomeGroups"];
        [query includeKey:aHomeGroupRegionPointer];
        [query whereKey:aHomeGroupRegionPointer equalTo:self.regionObject];
    }
    return query;
}

#pragma mark - UITABLEVIEW DELEGATE AND DATA SOURCE METHODS
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    PFObject* location = self.objects[indexPath.row];
    if (indexPath.row == self.objects.count) {
        UITableViewCell* cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    } else {
        NSLog(@"This is a local group: %@", location.description);
        static NSString *CellIdentifier = @"localCell";
        LocalGroupCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell != nil) {
            [cell setUpGroup:location];
        }
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    // Get and return the load more cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.row == self.objects.count) {
        [self loadNextPage];
    } else {
        PFObject* selectedGroup = [self.objects objectAtIndex:indexPath.row];
        GroupDetailViewController* groupDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"groupDetailVC"];
        groupDetailVC.group = selectedGroup;
        [self.navigationController pushViewController:groupDetailVC animated:YES];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
