//
//  SearchTableViewController.m
//  EngageCells
//
//  Created by Angela Smith on 2/20/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "SearchTableViewController.h"
#import <Parse/Parse.h>


@implementation SearchTableViewController


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"UniqueTags"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = @"UniqueTags";
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
    PFQuery *hashtagQuery = [PFQuery queryWithClassName:@"UniqueTags"];
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0) { //|| ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [hashtagQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return hashtagQuery;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;  // put the results here
    self.searchController.dimsBackgroundDuringPresentation = NO; // show filtered results under
    self.searchController.searchBar.delegate = self; // create the search bar and set delegate
    // set the search bar as the header
    self.tableView.tableHeaderView = self.searchController.searchBar;
    // since the search view covers the table view when active we make the table view controller define the presentation context
    self.definesPresentationContext = YES;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TagCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TagCell"];
    }
    // Configure the cell...
    if (self.searchController.active) {
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        PFObject* tagObject = [self.objects objectAtIndex:indexPath.row];
        NSString* tagString = [tagObject objectForKey:@"Name"];
        cell.textLabel.text = [NSString stringWithFormat:@"#%@", tagString];
        if ([tagObject objectForKey:@"Count"]) {
            // set in text view
            NSString* countString;
            int posts = [[tagObject objectForKey:@"Count"] intValue];
            countString = [NSString stringWithFormat:@"%d Stories", posts];
            cell.detailTextLabel.text = countString;
        }
    }
    return cell;
}

// implement the delegate to show new filtered results
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    // get the tags
    for (PFObject* tag in self.objects) {
        NSString* tagName = [tag objectForKey:@"Name"];
        [self.tagArray addObject:tagName];
    }
    NSString *searchString = searchController.searchBar.text;
    self.searchResults = nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@", searchString];
   // NSArray*
    self.searchResults = [[self.tagArray filteredArrayUsingPredicate:predicate] mutableCopy];
    [self.tableView reloadData];
}


@end