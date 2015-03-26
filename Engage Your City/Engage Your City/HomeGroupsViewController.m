//
//  HomeGroupsViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 2/24/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "HomeGroupsViewController.h"
#import "AppDelegate.h"
#import "LocalFullListViewController.h"


@interface HomeGroupsViewController ()

@end

@implementation HomeGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Fix the search bar
    self.searchBar.barTintColor = [UIColor colorWithRed:0.14 green:0.59 blue:0.76 alpha:1];
    searchView.backgroundColor = [UIColor colorWithRed:0.14 green:0.59 blue:0.76 alpha:1];
    self.searchBar.backgroundImage = [UIImage new];
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    //UIBarButtonItem* flexSpace = [[]
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(closeSearchKeyboard)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flex, doneButton, nil]];
    self.searchBar.inputAccessoryView = keyboardDoneButtonView;
    // Do any additional setup after loading the view.
}

-(void)closeSearchKeyboard {
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClick:(UIButton*)button {
    switch (button.tag) {
        case 0:
            NSLog(@"Opening Region view to browse groups");
            break;
        case 1:
            NSLog(@"User wants to use location to find a group");
            break;
        case 2:
            NSLog(@"User wants to search keyword for a group");
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

#pragma mark UISEARHCBAR DELEGATE
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString* searchString = searchBar.text;
    if (![searchString isEqualToString:@""]) {
        NSLog(@"Search entered %@", searchString);
        [searchBar resignFirstResponder];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        LocalFullListViewController* listVC = (LocalFullListViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"localGroupFullList"];
        listVC.searchTerm = searchString;
        listVC.searchList = true;
        [self.navigationController pushViewController:listVC animated:YES];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}


@end
