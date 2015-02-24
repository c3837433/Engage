//
//  ObjectSearchTableViewController.m
//  EngageCells
//
//  Created by Angela Smith on 2/23/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "ObjectSearchTableViewController.h"
#import "UniqueTag.h"
#import <Parse/Parse.h>

@interface ObjectSearchTableViewController () <UISearchBarDelegate, UISearchResultsUpdating>

@end

@implementation ObjectSearchTableViewController
@synthesize tagArray;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 64.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    if (!tagArray) {
        // get some
        // Search for tags
        PFQuery *hashtagQuery = [PFQuery queryWithClassName:@"UniqueTags"];
        //  [hashtagQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [hashtagQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects) {
                NSLog(@"Objects = %lu", (unsigned long)objects.count);
                tagArray = [[NSMutableArray alloc] init];
                // uniqueObjectArray = [[NSMutableArray alloc] init];
                for (PFObject* tagObject in objects) {
                    //  UniqueTag* tag = [UniqueTag object];
                    NSString* tagName = [tagObject objectForKey:@"Name"];
                    NSLog(@"Adding %@ tag",tagName);
                    //  tag.tagCount = [[tagObject objectForKey:@"Count"] intValue];
                    [tagArray addObject:tagName];
                    // [uniqueObjectArray addObject:tagName];
                }
                // NSLog(@"Completed getting tags, reloading tableview with %ld tags", uniqueObjectArray.count);
                //  [self.tableView reloadData];
            }
        }];
    }
    NSLog(@"Searching for tags");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredList count];
        
    } else {
        return [tagArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TagCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TagCell"];
    }
    
    //UniqueTag* tag = nil;
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
         cell.textLabel.text = [self.filteredList objectAtIndex:indexPath.row];
      
        
    } else {
        
       // tag = [tag objectAtIndex:indexPath.row];
        cell.textLabel.text = [self.tagArray objectAtIndex:indexPath.row];
       // NSString* countString = [NSString stringWithFormat:@" %d posts", tag.tagCount];
       // cell.detailTextLabel.text = countString;
    }
    
    
    return cell;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    if (tagArray)
    {
        self.filteredList = nil;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@", searchText];
        self.filteredList = [tagArray filteredArrayUsingPredicate:predicate];
        
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;
    NSLog(@"Tag selected = %@", cellText);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        NSIndexPath *indexPath = nil;
    NSString* selectedTag;
      //  UniqueTag *tag = nil;
        // Get the selected tag
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            selectedTag = [self.filteredList objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            selectedTag = [tagArray objectAtIndex:indexPath.row];
        }
     NSLog(@"Selected tag string = %@", selectedTag);
        
        //RecipeDetailViewController *destViewController = segue.destinationViewController;
        //destViewController.recipe = recipe;
}

@end
