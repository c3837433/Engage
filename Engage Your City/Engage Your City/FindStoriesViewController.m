//
//  FindStoriesViewController.m
//  Engage
//
//  Created by Angela Smith on 2/19/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "FindStoriesViewController.h"
#import "HashTagViewController.h"
#import "MBProgressHUD.h"

#import <Parse/Parse.h>
@interface FindStoriesViewController ()

@property (nonatomic) NSMutableArray *searchResults;
@end

@implementation FindStoriesViewController
@synthesize tagArray;

// Reload the table when returning from comment view
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [searchBar setBackgroundImage:[UIImage new]];
    [searchBar setTranslucent:YES];
    [searchBar setImage:[UIImage imageNamed:@"searchIcon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    if (!tagArray) {
        // Start Hud
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        // get some
        // Search for tags
        PFQuery *hashtagQuery = [PFQuery queryWithClassName:@"UniqueTags"];
        //  [hashtagQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [hashtagQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects) {
               // NSLog(@"Objects = %lu", (unsigned long)objects.count);
                tagArray = [[NSMutableArray alloc] init];
                for (PFObject* tagObject in objects) {
                    NSString* tagName = [tagObject objectForKey:@"Name"];
                    //NSLog(@"Adding %@ tag",tagName);
                    [tagArray addObject:tagName];
                }
                // Remove the hud
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            } else {
                // Remove the hud anyway
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [self.filteredList objectAtIndex:indexPath.row];
        
    } else {
        cell.textLabel.text = [self.tagArray objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    if (tagArray)
    {
        self.filteredList = nil;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@", searchText];
        self.filteredList = [tagArray filteredArrayUsingPredicate:predicate];
        
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString* selectedTag = cell.textLabel.text;
    NSLog(@"Tag selected = %@", selectedTag);
    HashTagViewController* hashTagVC = [self.storyboard instantiateViewControllerWithIdentifier:@"hashtagVC"];
    hashTagVC.seletedHashtag = selectedTag;
    [self.navigationController pushViewController:hashTagVC animated:YES];
}



@end
