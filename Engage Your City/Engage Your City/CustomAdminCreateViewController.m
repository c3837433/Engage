//
//  CustomAdminCreateViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 3/25/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "CustomAdminCreateViewController.h"
#import "MZFormSheetController.h"
#import "AdminSearchTableViewController.h"
#import "ApplicationKeys.h"
#import <QuartzCore/QuartzCore.h>


@interface CustomAdminCreateViewController ()

@end

@implementation CustomAdminCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hasUserChosen = false;
    // Do any additional setup after loading the view.
    UIBarButtonItem* stopBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(onClick:)];
    stopBtn.tag = 0;
    // create the two buttons
    self.navigationItem.rightBarButtonItem = stopBtn;
    if (self.viewType == 2) {
        // Set up for Local Leader Creation
        [self changeViewForLocalLeaderSetUp];
    }
    userView.hidden = true;
}

-(void)changeViewForLocalLeaderSetUp {
    NSLog(@"User is setting a local Leader");
    self.navigationItem.title = @"Create Local Group";
    self.regionGroupLabel.text = @"Enter a Name for this Group";
    self.searchUserLabel.text = @"Search for User to set as Leader";
    self.nameField.placeholder = @"General Location, City";
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
        self.hasUserChosen = nil;
        self.chosenUser = nil;
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        }];
    }
    else if (button.tag == 1) {
        NSLog(@"User pressed search button");
        self.hasUserChosen = false;
        // get entered text
        NSString* searchText = self.userNameField.text;
        if (![searchText isEqualToString:@""]) {
            NSLog(@"User entered: %@", searchText);
        }
    } else if (button.tag == 2) {
        NSLog(@"user wants to create");
        if ((self.hasUserChosen) && (self.chosenUser != nil)) {
            NSLog(@"We have a user");
            if (![self.nameField.text isEqualToString:@""]) {
                NSLog(@"We have a name");
                if (self.viewType == 2) {
                    // this is a local group
                    [self createNewEngageLocalGroup:self.nameField.text localLeader:self.chosenUser];
                } else if (self.viewType == 1) {
                    [self createNewEngageRegion:self.nameField.text regionDirector:self.chosenUser];
                }
                
            } else {
                self.nameField.layer.cornerRadius=8.0f;
                self.nameField.layer.masksToBounds=YES;
                self.nameField.layer.borderColor=[[UIColor redColor]CGColor];
                self.nameField.layer.borderWidth= 1.0f;
            }
        } else {
            self.userNameField.layer.cornerRadius=8.0f;
            self.userNameField.layer.masksToBounds=YES;
            self.userNameField.layer.borderColor=[[UIColor redColor]CGColor];
            self.userNameField.layer.borderWidth= 1.0f;
        }
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    textField.layer.borderColor = borderColor.CGColor;
    //textField.layer.borderColor=[[UIColor lightGrayColor] CGColor];
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

#pragma mark - Segue Methods //textCommentSegue  postImageSegueToComment
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton*)sender {
    if ([segue.identifier isEqualToString:@"segueToListView"]) {
        self.hasUserChosen = false;
        AdminSearchTableViewController* adminTableVC = segue.destinationViewController;
        adminTableVC.nameSearch = self.userNameField.text;
    }
}

-(IBAction)didSelectUser:(UIStoryboardSegue*)segue {
    NSLog(@"User did select a user");
    AdminSearchTableViewController* adminTableVC = [segue sourceViewController];
    [self setViewWithUser:[adminTableVC selectedUser]];
 
}

-(void) setViewWithUser:(PFUser*)user {
    self.chosenUser = user;
    if (user != nil) {
        createButton.enabled = true;
    }
    self.hasUserChosen = true;
    userView.hidden = false;
    self.userEmailLable.text = [self.chosenUser objectForKey:aUserEmail];
    self.userNameLabel.text = [self.chosenUser objectForKey:aUserName];
    self.userProfileImageView.file = [self.chosenUser objectForKey:aUserImage];
    [self.userProfileImageView loadInBackground];
    NSLog(@"The selected user's name: %@", [self.chosenUser objectForKey:aUserName]);
    // make sure the keyboard is down
    self.userNameField.text = [self.chosenUser objectForKey:aUserName];
    [self.userNameField resignFirstResponder];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark CREATE ROLE METHODS
-(void)createNewEngageRegion:(NSString*)regionName regionDirector:(PFUser*)director {
    // get the admin role
    PFQuery *queryRole = [PFRole query];
    [queryRole whereKey:@"name" equalTo:@"Admin"];
    [queryRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFRole *role = (PFRole *)object;
        // must be admin
        PFObject* region = [PFObject objectWithClassName:aRegionClass];
        [region setObject:regionName forKey:aRegionName];
        [region setObject:director forKey:aRegionDirector];
        PFACL* acl = [PFACL ACL];
        [acl setWriteAccess:YES forRole:role];
        [region setACL:acl];
        [region saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"New region created");
                // save this user as a regional director
                [self createNewRgionalDirectorRoleWithUser:director forRegion:regionName];
            } else {
                NSString* message = [NSString stringWithFormat:@"Sorry, we were unable to create a region named \"%@\".", regionName];
                [self returnToSettingsWithSuccess:succeeded andMessage:message];
            }
        }];
    }];
}

-(void)createNewRgionalDirectorRoleWithUser:(PFUser*)newUser forRegion:(NSString*)region{
    // Must be admin, need user and region, upon success notify user
    PFQuery *queryRole = [PFRole query];
    NSString* userName = [newUser objectForKey:aUserName];
    [queryRole whereKey:@"name" equalTo:@"RegionalDirector"];
    [queryRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFRole *role = (PFRole *)object;
        [role.users addObject:newUser];
        [role saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Saved this user as a regional director");
                NSString* message = [NSString stringWithFormat:@"%@ was successfully set as Director for %@.", userName, region];
                [self returnToSettingsWithSuccess:succeeded andMessage:message];
                
            } else {
                NSString* message = [NSString stringWithFormat:@"Sorry, we were able to create a region named \"%@\", but we were unable to set %@ as the director.", region, userName];
                [self returnToSettingsWithSuccess:succeeded andMessage:message];
            }
        }];
        
    }];
}

// Create new LOCAL GROUP
-(void)createNewEngageLocalGroup:(NSString*)groupName localLeader:(PFUser*)leader {
    // get the admin role
    PFQuery *queryRole = [PFRole query];
    [queryRole whereKey:@"name" equalTo:@"RegionalDirector"];
    [queryRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFRole *role = (PFRole *)object;
        // must be at least a regional director
        PFObject* group = [PFObject objectWithClassName:aHomeGroupClass];
        [group setObject:groupName forKey:aHomeGroupTitle];
        [group addObject:leader.objectId forKey:aHomegroupLeadersArray];
        PFACL* acl = [PFACL ACL];
        [acl setWriteAccess:YES forRole:role];
        [group setACL:acl];
        [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"New local group created");
                [self createNewLocalLeaderRoleForUser:leader forGroup:groupName];
            } else {
                NSString* message = [NSString stringWithFormat:@"Sorry, we were unable to create a local group named \"%@\".", groupName];
                [self returnToSettingsWithSuccess:succeeded andMessage:message];
            }
        }];
    }];
}

-(void) createNewLocalLeaderRoleForUser:(PFUser*)leader forGroup:(NSString*)group{
    PFQuery *queryRole = [PFRole query];
    NSString* userName = [leader objectForKey:aUserName];
    [queryRole whereKey:@"name" equalTo:@"LocalLeader"];
    [queryRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFRole *role = (PFRole *)object;
        [role.users addObject:leader];
        [role saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Saved this user as a local leader");
                NSString* message = [NSString stringWithFormat:@"%@ was successfully set as a Local Leader for %@.", userName, group];
                [self returnToSettingsWithSuccess:succeeded andMessage:message];
                
            } else {
                NSString* message = [NSString stringWithFormat:@"Sorry, we were able to create a local group named \"%@\", but we were unable to set %@ as a leader.", group, userName];
                [self returnToSettingsWithSuccess:succeeded andMessage:message];
            }
        }];
        
    }];
}


-(void) returnToSettingsWithSuccess:(BOOL)success andMessage:(NSString*)message {
    // set the confirmation to the page
    if ([self.delegate respondsToSelector:@selector(viewController:returnRoleCreated:withMessage:)]) {
        [self.delegate viewController:self returnRoleCreated:success withMessage:message];
    }
    // and return to settings
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
}


@end
