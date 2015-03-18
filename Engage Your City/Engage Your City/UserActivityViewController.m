//
//  UserActivityViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 3/1/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "UserActivityViewController.h"
#import "AppDelegate.h"
#import "ApplicationKeys.h"

@interface UserActivityViewController ()

@end

@implementation UserActivityViewController


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithStyle:UITableViewStylePlain];
    self = [super initWithClassName:@"Activity"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = @"Activity";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of user stories to show per page
        self.objectsPerPage = 5;
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
    // Find all activities for this user
    // find all activity that is directed to the user
    [query whereKey:aActivityToUser equalTo:[PFUser currentUser]];
    // find all the activity that was not created by the user
    [query whereKey:aActivityFromUser notEqualTo:[PFUser currentUser]];
    [query whereKey:aActivityType notEqualTo:@"joined"];
    // where the user is connected
    [query whereKeyExists:aActivityFromUser];
    // include the poster
    [query includeKey:aActivityFromUser];
    [query includeKey:aActivityToUser];
    // and story object
    [query includeKey:aActivityStory];
    // order newest first
    [query orderByDescending:@"createdAt"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return query;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
