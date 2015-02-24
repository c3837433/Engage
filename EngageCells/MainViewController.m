//
//  MainViewController.m
//  EngageCells
//
//  Created by Angela Smith on 2/5/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[PFUser requestPasswordResetForEmailInBackground:@"angessmith@gmail.com"];
    [PFUser logInWithUsernameInBackground:@"a@a.com"  password:@"a"
                                    block:^(PFUser *user, NSError *error) {
                                        if (error) {
                                            NSLog(@"error: %@", error.userInfo);
                                        }
                                    }];

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
