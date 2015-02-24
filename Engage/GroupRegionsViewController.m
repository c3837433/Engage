//
//  GroupRegionsViewController.m
//  Test Engage
//
//  Created by Angela Smith on 10/29/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "GroupRegionsViewController.h"
#import "GroupsListViewController.h"
#import "AppDelegate.h"

@interface GroupRegionsViewController ()

@end

@implementation GroupRegionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    NSLog(@"The view loaded for selecting a region");
    // load the available regions available
    [self getNumberofRegions];
}

#pragma mark PARSE QUERY METHODS
-(void)getNumberofRegions
{
    PFQuery* query = [PFQuery queryWithClassName:@"HomeGroups"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray* regions = [[NSMutableArray alloc] init];
            for (PFObject* object in objects) {
                NSString* region = [object objectForKey:@"region"];
                [regions addObject:region];
            }
            regionsAvailable = [self getCountAndRemoveMultiples:regions];
            NSLog(@"There are %lu regions available", (unsigned long)regionsAvailable.count);
            [regionTable reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(NSMutableArray *)getCountAndRemoveMultiples:(NSArray*)array{
    // Remove the duplicates and get the number of regions available righ now
    NSMutableArray* groupsInRegion = [[NSMutableArray alloc] init];
    for (NSString* eachString in array)
    {
        if (![groupsInRegion containsObject:eachString])
        {
            [groupsInRegion addObject:eachString];
        }
    }
    return groupsInRegion;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"User clicked join now");
    }
    else {
        NSLog(@"User clicked Join Later");
        // Save the selected group preference
        NSLog(@"Saving inGroup for key HomeGroupSet");
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"noGroup" forKey:@"HomeGroupSet"];
        [userDefaults synchronize];
        
        // switch to the main view
        AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate switchToMainView];
    }
}


-(IBAction)onCancelGroupSelect:(UIButton*)button
{
    [[[UIAlertView alloc] initWithTitle:@"Not ready? No problem!" message:@"Your story feed will be empty, but you can always join a group or follow friends to find some." delegate:self cancelButtonTitle:@"Join Now" otherButtonTitles:@"Join Later", nil] show];
}

#pragma mark TABLEVIEW METHODS
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return regionsAvailable.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"regionsCell"];
    //NSLog(@"The region in the cell is %@", regionsAvailable.description);
    cell.textLabel.text = [regionsAvailable objectAtIndex:indexPath.row];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"regionsToGroupsSegue"]) {
        NSIndexPath *indexPath = [regionTable indexPathForSelectedRow];
        GroupsListViewController *groupListVC = segue.destinationViewController;
        groupListVC.selectedRegion = [regionsAvailable objectAtIndex:indexPath.row];
    }
}


@end
