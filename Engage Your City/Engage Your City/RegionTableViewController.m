//
//  RegionTableViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 3/26/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "RegionTableViewController.h"
#import "ApplicationKeys.h"
#import "AppDelegate.h"
#import "LocalFullListViewController.h"

@interface RegionTableViewController ()

@end

@implementation RegionTableViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithStyle:UITableViewStyleGrouped];
    self = [super initWithClassName:@"Region"];
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
    PFQuery* query = [PFQuery queryWithClassName:@"Region"];
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return query;
}

#pragma mark - UITABLEVIEW DELEGATE AND DATA SOURCE METHODS
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {

    PFObject* location = self.objects[indexPath.row];
    if (indexPath.row == self.objects.count) {
        UITableViewCell* cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    else {
        NSLog(@"This is a region");
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"regionCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"regionCell"];
        }
        cell.textLabel.text = [location objectForKey:aRegionName];
        NSString* numberOfGroups = [NSString stringWithFormat:@"%@", [location objectForKey:aRegionHomeGroupsCount]];
        cell.detailTextLabel.text = numberOfGroups;
        return cell;
    }
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    // Get and return the load more cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
      [tableView deselectRowAtIndexPath:indexPath animated:NO];
    /*
    if (indexPath.row == self.objects.count) {
        [self loadNextPage];
    } else {
        PFObject* selectedObject = [self.objects objectAtIndex:indexPath.row];
                   NSLog(@"User selected a region: %@", [selectedObject objectForKey:aRegionName]);

        //PFObject* selectedGroup = [self.objects objectAtIndex:indexPath.row];
        //GroupDetailViewController* groupDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"groupDetailVC"];
        //groupDetailVC.group = selectedGroup;
        //[self.navigationController pushViewController:groupDetailVC animated:YES];
        
    }
;*/
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     LocalFullListViewController* localViewList = [segue destinationViewController];
     NSIndexPath *selectedPath = [self.tableView indexPathForCell:sender];
     PFObject* region = self.objects[selectedPath.row];
     localViewList.regionObject = region;

 }



@end
