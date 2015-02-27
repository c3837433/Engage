//
//  CustomSearchViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 2/25/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "CustomSearchViewController.h"
#import "MZFormSheetController.h"
@interface CustomSearchViewController ()

@end

@implementation CustomSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem* stopBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(onClick:)];
    stopBtn.tag = 0;
    // create the two buttons
    self.navigationItem.rightBarButtonItem = stopBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Access to form sheet controller
    MZFormSheetController *controller = self.navigationController.formSheetController;
    controller.shouldDismissOnBackgroundViewTap = YES;
    
}

-(IBAction)onClick:(UIButton* )button {
    if (button.tag == 0) {
        NSLog(@"User wants to cancel add item");
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        }];
    }
    else if (button.tag == 1) {
        NSLog(@"User pressed search button");
        // get entered text
        NSString* searchText = self.searchField.text;
        if (![searchText isEqualToString:@""]) {
            NSLog(@"User entered: %@", searchText);
            if ([self.delegate respondsToSelector:@selector(viewController:returnSearchString:)]) {
                [self.delegate viewController:self returnSearchString:searchText];
            }
            
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                
            }];
        }
    }
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.showStatusBar = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.formSheetController setNeedsStatusBarAppearanceUpdate];
    }];
    
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent; // your own style
}

- (BOOL)prefersStatusBarHidden {
    //    return self.showStatusBar; // your own visibility code
    return NO;
}


@end
