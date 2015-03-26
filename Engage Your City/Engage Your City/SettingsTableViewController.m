//
//  SettingsTableViewController.m
//  Engage
//
//  Created by Angela Smith on 8/10/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "SettingsTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Utility.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "ApplicationKeys.h"
#import "MZCustomTransition.h"

@interface SettingsTableViewController () {
  //  NSMutableArray* rolesArray;
   // NSDictionary *userRole;
    NSInteger roleKey;
    BOOL haveRoles;
}

@end

@implementation SettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
 //   rolesArray = [[NSMutableArray alloc] init];
    roleKey = 0;
    haveRoles = false;
    // Check if user has admin or group leader access
    PFQuery *query = [PFRole query];
    [query whereKey:@"users" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSLog(@"Checking if user has a role");
        if (object) {
            NSLog(@"User has a role");
            haveRoles = true;
            PFRole* role = (PFRole*) object;
            NSString* roleName = [role objectForKey:@"name"];
            NSLog(@"Role name: %@", roleName);
            if ([roleName isEqual:@"Admin"]) {
                roleKey = 3;
                //userRole = [[NSDictionary alloc]  initWithObjectsAndKeys:@"Admin", [NSNumber numberWithInt:(int)3], nil];
            } else if ([roleName isEqual:@"RegionalDirector"]) {
                roleKey = 2;
            } else  {
                roleKey = 1;
            }
            // when done gathering the roles, reload the table with admin section
            [settingsTable reloadData];
        }
    }];
    // set up the custom search view
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    
    [MZFormSheetController registerTransitionClass:[MZCustomTransition class] forTransitionStyle:MZFormSheetTransitionStyleCustom];
    [super viewDidLoad];
}

#pragma mark - Add Post Delegate
-(void) viewController:(UIViewController *)viewController returnRoleCreated:(BOOL)created withMessage:(NSString*)message {
  //  NSLog(@"Returned from post with saved %d", created);
    [self alertUserWithMessage:message];
}

-(void) alertUserWithMessage:(NSString*) alertMessage {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

}


-(void)viewDidAppear:(BOOL)animated {
    
     [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* linkable = [userDefaults objectForKey:@"FBLinkable"];
    // IF the user is linkable, then they can link
    canLink = (linkable) ? YES : NO;
    user = [PFUser currentUser];
    // See if the current user is connected with Facebook yet
    connectedToFacebook = ([PFFacebookUtils isLinkedWithUser:user]) ? YES : NO;
    // check if the user is connected to facebook (for sync button)
    
    // Set up the toggle button
    [self setUpFacebookToggle];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TABLEVIEW DATA SOURCE METHODS
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (haveRoles) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (connectedToFacebook) {
            return 2;
        }
        return 1;
    }
    else if (section == 1) {
        return 1;
    }
    else if (haveRoles) {
    NSLog(@"Role Key %ld", roleKey);
        switch (roleKey) {
            case 3:
                // admin, section 2 == 2, 3 & 4 = 0
                if (section == 2) {
                    return 2;
                } else  {
                    return 0;
                }
                break;
            case 2:
                // regional, section 2 & 4 == 0, 3 == 1
                if (section == 3) {
                    return 1;
                } else {
                    return 0;
                }
                break;
            case 1:
                // local section 2 & 3,== 0, 4 == 1
                if (section == 4) {
                    return 1;
                } else {
                    return 0;
                }
                break;
            default:
                return 0;
                break;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Change the color of the header text in each section
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.textColor = [UIColor colorWithRed:0.07 green:0.57 blue:0.76 alpha:1];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ((section == 0) || (section == 1)) {
        return 50;
    } else {
        if (haveRoles) {
            switch (roleKey) {
                case 3:
                    // admin, section 2 == 2, 3 & 4 = 0
                    if (section == 2) {
                        return 50;
                    } else  {
                        return 0;
                    }
                    break;
                case 2:
                    // regional, section 2 & 4 == 0, 3 == 1
                    if (section == 3) {
                        return 50;
                    } else {
                        return 0;
                    }
                    break;
                case 1:
                    // local section 2 & 3,== 0, 4 == 1
                    if (section == 4) {
                        return 50;
                    } else {
                        return 0;
                    }
                    break;
                default:
                    return 0;
                    break;
            }

        }
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
            NSLog(@"This section was selected: %ld", (long)indexPath.section);
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            // Updating user information
            //NSLog(@"Updating user information");
            [self updateFacebookDataForUser];
        }
        // toggle connect to facebook
    } else if (indexPath.section == 1) {
        // log out the user
        [self logOutUser];
    } else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            // User wants to create a regional director
            NSLog(@"User pressed the first button");
            [self openCreateRoleViewForType:1];
        } else {
            NSLog(@"User pressed the second button");
            [self openCreateRoleViewForType:2];
        }
    }
}

-(void)setUpFacebookToggle {
    // Set switch based on whether the user is logged in with facebook or not
    // See if the current user is connected with Facebook yet
    if (![PFFacebookUtils isLinkedWithUser:user]) {
        //NSLog(@"They can connect, toggle should be off");
        [toggleFBConnect setOn:FALSE animated:TRUE];
        
    } else if ([PFFacebookUtils isLinkedWithUser:user]) {
        //NSLog(@"They are connected, toggle should be on");
        [toggleFBConnect setOn:TRUE animated:TRUE];
    }
}

- (IBAction)linkToFacebook:(id)sender {

    if (![PFFacebookUtils isLinkedWithUser:user]) {
        [PFFacebookUtils linkUser:user permissions:nil block:^(BOOL succeeded, NSError *error) {
             if (succeeded) {
                 NSLog(@"Connected user with Facebook!");
                 [toggleFBConnect setOn:TRUE animated:TRUE];
                 // reload the table so the sync buton is available
                 [settingsTable reloadData];
             }
             else {
                 NSLog(@"Error connecting user with Facebook!");
                 [toggleFBConnect setOn:FALSE animated:TRUE];
                 // If this email does not match the current one
                 if (error.code == 208) {
                     // Alert user
                     [[[UIAlertView alloc] initWithTitle:@"Different Accounts"  message:@"The current Facebook account does not match the registered email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                 }
             }
         }];
    }
    // When the user is linked with Facebook already
    else if ([PFFacebookUtils isLinkedWithUser:user]) {
        
        [PFFacebookUtils unlinkUserInBackground:user block:^(BOOL Success,NSError *unlinkError) {
             if(!unlinkError) {
                 NSLog(@"Disconnected user with Facebook!");
                 [toggleFBConnect setOn:FALSE animated:TRUE];
                 // reload table to hide sync button
                 [settingsTable reloadData];
             }
             else {
                 NSLog(@"Error disconnecting user with Facebook!");
                 [toggleFBConnect setOn:TRUE animated:TRUE];
             }
         }];
    }
    [self.view setNeedsDisplay];
    [settingsTable reloadData];
}
// When the user wants to sync facebook data on the settings view
-(void)updateFacebookDataForUser {
    // Show HUD view as the data is gathered
    [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    // Get the current user from parse
    PFQuery* query = [PFUser query];
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    NSLog(@"Making query");
    [query getFirstObjectInBackgroundWithBlock:^(PFObject* userInfo, NSError* queryError) {
        if (!queryError) {
            NSLog(@"No query error");
            // Get the Facebook Data
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)  {
                NSLog(@"Getting Result");
                if (!error) {
                     // get the returned data
                     NSLog(@"%@", result);
                     NSString* facebookUserName = [result objectForKey:@"name"];
                     NSString* facebookUserEmail = [[result objectForKey:@"email"] lowercaseString]; // For case insensitivity
                     NSString* userId = [result objectForKey:@"id"];
                     // Update the remaining data
                     // get the user's current profile picture
                     NSURL* userProfilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",userId]];
                     // Make the request for the image with the timeout interval
                     NSURLRequest* profilePicURLRequest = [NSURLRequest requestWithURL:userProfilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
                     // Send the request
                     [NSURLConnection connectionWithRequest:profilePicURLRequest delegate:self];
                     // Use the NSURLConnectionDataDelegate to get the data
                     
                     [userInfo setObject:facebookUserEmail forKey:@"email"];
                     [userInfo setObject:facebookUserName forKey:@"UsersFullName"];
                     NSLog(@"Saving info");
                     [userInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if (error)
                         {
                             NSLog(@"%ld", (long)error.code);
                             // Alert user
                             [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"We are unable to sync your profile with Facebook right not. Try again later." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil]show];
                             // Deselect the row
                             [settingsTable deselectRowAtIndexPath:[settingsTable indexPathForSelectedRow] animated:YES];
                         }
                         else if (succeeded)
                         {
                             //NSLog(@"User data was updated");
                             // Alert user
                             [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Great! Your Engage profile was synced with Facebook" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil]show];
                             // Deselect the row
                             [settingsTable deselectRowAtIndexPath:[settingsTable indexPathForSelectedRow] animated:YES];
                             
                         }
                     }];
                     // Remove the hud
                     [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
                 } else
                 {
                     NSLog(@" Error = %@", error);
                 }
             }];
            
            // Save
            //[userInfo saveInBackground];
        } else {
            // Error for query
            NSLog(@"Error: %@", queryError);
        }
        
    }];
}

-(void) openCreateRoleViewForType:(NSInteger)type {
    NSLog(@"We need to display create view");
    
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"customCreateUserRole"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    CustomAdminCreateViewController* customControl = (CustomAdminCreateViewController*) vc.topViewController;
    customControl.delegate = self;
    customControl.viewType = type;
    
    formSheet.presentedFormSheetSize = CGSizeMake(320, 480);
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.shouldCenterVertically = YES;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    __weak MZFormSheetController *weakFormSheet = formSheet;
    
    
    // If you want to animate status bar use this code
    formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
        UINavigationController *navController = (UINavigationController *)weakFormSheet.presentedFSViewController;
        if ([navController.topViewController isKindOfClass:[CustomAdminCreateViewController class]]) {
            CustomAdminCreateViewController* adminView = (CustomAdminCreateViewController *)navController.topViewController;
            adminView.showStatusBar = NO;
           // adminView.viewType = type;
        }
        
        
        [UIView animateWithDuration:0.3 animations:^{
            if ([weakFormSheet respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [weakFormSheet setNeedsStatusBarAppearanceUpdate];
            }
        }];
    };
    formSheet.transitionStyle = MZFormSheetTransitionStyleCustom;
    
    [MZFormSheetController sharedBackgroundWindow].formSheetBackgroundWindowDelegate = self;
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}

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
                [self createNewRgionalDirectorRoleWithUser:director];
            }
        }];
    }];
     
    
}

-(void)createNewRgionalDirectorRoleWithUser:(PFUser*)newUser {
    // Must be admin, need user and region, upon success notify user
    PFQuery *queryRole = [PFRole query];
    [queryRole whereKey:@"name" equalTo:@"RegionalDirector"];
    [queryRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFRole *role = (PFRole *)object;
            [role.users addObject:newUser];
            [role saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Saved this user as a regional director");
                }
            }];
        
    }];
}


-(void) createNewLocalGroupLeaderRole {
    // need user and region, must be admin or regional director, upon success notify user
}

-(void)createNewLocalGroup {
    // need leader, and region, increase local group count in region, notify user
    // must be admin or regional director
}

#pragma mark - NSURLConnectionDataDelegate
// If the user profile image data came back, begin creating the data object
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    facebookUserProfilePictureData = [[NSMutableData alloc] init];
}

// Add any new data to the object until it is completed
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [facebookUserProfilePictureData appendData:data];
}

// When the data has finished loading, save this to the current user
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Save the image to the current user
    [Utility saveFacebookImageData:facebookUserProfilePictureData];
}

-(void)logOutUser {

    // Remove the stack
    [self.navigationController popToRootViewControllerAnimated:NO];
    // Move back to log in screen
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate logOutUser];
}

@end
