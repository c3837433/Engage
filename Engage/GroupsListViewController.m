//
//  GroupsListViewController.m
//  Test Engage
//
//  Created by Angela Smith on 10/29/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "GroupsListViewController.h"
#import "HomeGroupTableViewCell.h"
#import "HomeGroupObject.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface GroupsListViewController ()

@end

@implementation GroupsListViewController
@synthesize currentSelection, progressHud, selectedRegion;

- (void)viewDidLoad {
    
        //NSLog(@"There are %d groupssuch as: %@", homeGroupsArray.count, homeGroupsArray.description);
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    defaults = [NSUserDefaults standardUserDefaults];
    // see what was selected
    NSLog(@"The selected region is %@", selectedRegion);
    homeGroupsArray = [[NSMutableArray alloc] init];
    // Load the groups
    [self LoadHomeGroups];
}

-(void)LoadHomeGroups {
    PFQuery* query = [PFQuery queryWithClassName:@"HomeGroups"];
    [query whereKey:@"region" equalTo:selectedRegion];
    [query whereKey:@"Joinable" equalTo:@"YES"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject* object in objects) {
            NSString* gLeader = [object objectForKey:@"resident"];
            NSString* gCity = [object objectForKey:@"City"];
            NSString* gMeetsOn = [object objectForKey:@"meetingDates"];
            NSString* gMeetsAt = [object objectForKey:@"meetingTime"];
            NSString* gAddress = [object objectForKey:@"Address"];
            NSString* gID = [object objectId];
            HomeGroupObject* group = [[HomeGroupObject alloc] initGroupObject:gCity leader:gLeader address:gAddress date:gMeetsOn time:gMeetsAt gId:gID];
            [homeGroupsArray addObject:group];
        }
        NSLog(@"The homegroups array contains %ld groups", (unsigned long)homeGroupsArray.count);
        [homegroupsTable reloadData];
    }];
    
}

#pragma mark TABLEVIEW METHODS
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return homeGroupsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     HomeGroupTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"groupsCell"];
     HomeGroupObject* group = [homeGroupsArray objectAtIndex:indexPath.row];
     NSString* meeting = [NSString stringWithFormat:@"Meets: %@ at %@", group.groupMeetDate, group.groupMeetTime];
     [cell refreshGroupList:group.groupCity leader:group.groupLeaders meets:meeting];
     return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check the current selected row
    NSIndexPath* thisSelectedPath = indexPath;
    // if it is not the same as the previous, remove the checkmark from the previous
    if (thisSelectedPath != selectedIndexPath) {
        [tableView cellForRowAtIndexPath:selectedIndexPath].accessoryType = UITableViewCellAccessoryNone;
        selectedIndexPath = thisSelectedPath;
        // set the selected row to the current row
    }
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    HomeGroupTableViewCell *cell = (HomeGroupTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSString* name = cell.groupLeaders.text;
    NSRange range = [name rangeOfString:@" " options:NSBackwardsSearch];
    NSString* lastName = [name substringFromIndex:range.location+1];
    selectedHomeGroup.text = [NSString stringWithFormat:@"%@'s in %@", lastName, cell.groupLocation.text];
    chooseGroupLabel.text = @"Selected Home Group";
    HomeGroupObject* group = [homeGroupsArray objectAtIndex:indexPath.row];
    userSelectedGroup = group.groupID;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(onGroupSelected)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:doneButton];
    //nextButton.enabled = YES;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 65;
}

-(void)onGroupSelected
{
    // Save the selected group
    PFUser* user = [PFUser currentUser];
    [user setObject:userSelectedGroup forKey:@"group"];
    user[@"group"] = [PFObject objectWithoutDataWithClassName:@"HomeGroups" objectId:userSelectedGroup];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"Saving inGroup for key HomeGroupSet");
            [defaults setObject:@"inGroup" forKey:@"HomeGroupSet"];
            [defaults synchronize];
        }
    }];

    // switch to the main view
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate switchToMainView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
