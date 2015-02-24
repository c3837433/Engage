//
//  AppDelegate.m
//  Engage
//
//  Created by Angela Smith on 8/17/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PanelViewController.h"
#import "LogInViewController.h"
#import "DataHelper.h"
#import "Utility.h"
#import "Cache.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "GroupRegionsViewController.h"
#import "RootViewController.h"
#import "Reachability.h"
#import "ApplicationKeys.h"


@implementation AppDelegate
@synthesize followTimer, progressHud;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // PARSE SOCIAL
    [Parse setApplicationId:@"3ifWZJRVr3Gv7SIvM1KCseAt8c0FPAKY0sPH6x2j"
                  clientKey:@"v8Ne000q83DP8xnae5YoE4aSBM5LjsFeKr1sLfs9"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // SET FACEBOOK OAUTH
    [PFFacebookUtils initializeFacebook];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }

    // Set default ACLs for parse so users can read data
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    // Override point for customization after application launch.
    
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    // APPEARANCE
    // Change nav bar tint color
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.07 green:0.57 blue:0.76 alpha:1]];
    // By specifying no write privileges for the ACL, we can ensure the role cannot be altered.
    
    // CODE TO ADD INDIVIDUALS TO ROLE POSITIONS
    /*
    PFQuery *queryRole = [PFRole query];
    [queryRole whereKey:@"name" equalTo:@"Admin"];
    [queryRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFRole *role = (PFRole *)object;
        PFQuery* userQuery = [PFUser query];
        [userQuery whereKey:@"email" equalTo:@"diana.malecha@gmail.com"];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            PFUser* user = (PFUser*) object;
            [role.users addObject:user];
            [role saveInBackground];
            NSLog(@"Added Diana to admin");
        }];
     
    }];
    
    PFQuery *leaderQuery = [PFRole query];
    [leaderQuery whereKey:@"name" equalTo:@"GroupLead"];
    [leaderQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFRole *role = (PFRole *)object;
        PFQuery* userQuery = [PFUser query];
        [userQuery whereKey:@"email" equalTo:@"stevesmithsb@gmail.com"];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            PFUser* user = (PFUser*) object;
            [role.users addObject:user];
            [role saveInBackground];
            NSLog(@"Added steve to leaders");
        }];

    }];
*/
    
    [self checkLogIn];
    userDefaults = [NSUserDefaults standardUserDefaults];
    return YES;
}

// FACEBOOK OAUTH
// Facebook Test User Log In
// email:       sherlock_cpfkskw_holmes@tfbnw.net
// password:    sherlock
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

-(void)checkLogIn
{
    // NAVIGATION AND LOG IN
    // Check if user is logged in or not
    if (![PFUser currentUser])
    {
        [self switchToLogInView];
    }
    else
    {
        // see if home group has been set
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* groupString = [defaults objectForKey:@"HomeGroupSet"];
        //NSLog(@"Group string = %@", groupString);
        if (([groupString isEqualToString:@"inGroup"]) ||([groupString isEqualToString:@"noGroup"])) {
            //NSLog(@"Group string has been set");
            [self switchToMainView];
            }
        else {
            //NSLog(@"Group string has not been set");
            // Run a user check
            PFQuery* userQuery = [PFUser query];
            [userQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
            [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                // this is a previously registered user
                if (object)
                {
                    // Find out if this is a new user by checkinf if permission default was set
                    NSString* homeGroupName = [object objectForKey:@"group"];
                    NSLog(@"Home Group = %@", homeGroupName);
                    if (homeGroupName != nil) {
                        NSLog(@"Home group set");
                        [userDefaults setObject:@"inGroup" forKey:@"HomeGroupSet"];
                        [userDefaults synchronize];
                        [self switchToMainView];
                    } else {
                        NSLog(@"Need to set home group");
                        needToSelectHomeGroup = true;
                        [self loadHomeGroupSelect];
                    }
                }
            }];

        }
    }
}
// MILESTONE 1:3 (Facebook Log In), and 1:6 (manual and facebook email match error)
// WHEN USER LOG IN IS SUCCESSFUL
-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    // Check to see if user is linked with facebook
    BOOL userLinkedWithFacebook = [PFFacebookUtils isLinkedWithUser:user];
    needToSelectHomeGroup = false;
    if (userLinkedWithFacebook)
    {
        //NSLog(@"The user logged in through Facebook");
        // If the user is linked, make a request for their data
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
         {
             if (!error)
             {
                 // get the result
                 NSLog(@"%@", result);
                 facebookUserName = [result objectForKey:@"name"];
                 facebookUserEmail = [[result objectForKey:@"email"] lowercaseString]; // For case insensitivity
                 NSString* userId = [result objectForKey:@"id"];
                 // get the user's current profile picture
                 NSURL* userProfilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",userId]];
                 // Make the request for the image, and set it to expire in 10 days (per Facebook policy)
                 NSURLRequest* profilePicURLRequest = [NSURLRequest requestWithURL:userProfilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
                 // Send the request
                 [NSURLConnection connectionWithRequest:profilePicURLRequest delegate:self];
                 // Use the NSURLConnectionDataDelegate to get the data
                 
                 // Make a query to verify that the user has not tried to connect with a Facebook email address that was user to register manually
                 PFQuery* userQuery = [PFUser query];
                 [userQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
                 [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                     // this is a previously registered user
                     if (object)
                     {
                         // Find out if this is a new user by checkinf if permission default was set
                         NSString* permissionString = [object objectForKey:@"sharePermission"];
                         NSString* fbLinkable = [object objectForKey:@"FBLinkable"];
                         NSString* homeGroupName = [object objectForKey:@"group"];
                         //NSLog(@"Permission = %@, Facebook linkable = %@, Home Group = %@", permissionString, fbLinkable, homeGroupName);
                         needToSelectHomeGroup = false;
                         if (homeGroupName != nil) {
                             NSLog(@"Home group set");
                             [userDefaults setObject:@"inGroup" forKey:@"HomeGroupSet"];
                             [userDefaults synchronize];
                             needToSelectHomeGroup = false;
                        } else {
                             //NSLog(@"Need to set home group");
                             needToSelectHomeGroup = true;
                             //[self loadHomeGroupSelect];
                         }
                         // If not there, this is a new user
                         if (permissionString == nil)
                         {
                             //NSLog(@"This is a new user");
                             // User this persons facebook name, email, and id to register them
                             user.email = facebookUserEmail;
                             [user setObject:facebookUserName forKey:@"UsersFullName"];
                             [user setObject:userId forKey:@"facebookId"];
                             [user setObject:@"NO" forKey:@"sharePermission"];
                             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                 if (error) {
                                     
                                     // If the error code is 203, then we already have this user's email in the database, alert the user they can connect this account in settings (prevents double log ins)
                                     NSLog(@"%ld", (long)error.code);
                                     if (error.code == 203)
                                     {
                                         // this email is already registered
                                         [[[UIAlertView alloc] initWithTitle:@"Wow, you're awesome!"  message:@"Looks like you have registered already. You can sign in with your username then link to Facebook in your Profile." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                     }
                                     // delete the user that was created as part of Parse's Facebook login
                                     [user deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                         if (succeeded)
                                         {
                                             // Remove Facebook information too
                                             [[FBSession activeSession] closeAndClearTokenInformation];
                                         }
                                     }];
                                 } else if (succeeded)
                                 {
                                     [userDefaults setObject:@"NO" forKey:@"sharePermission"];
                                     [userDefaults synchronize];
                                     //NSLog(@"saving %@ for full name, and %@ for email", facebookUserName, facebookUserEmail);
                                     // Get their list of friends
                                     [self findFacebookFriends];
                                     // Finally, close the log in view and present the next view
                                     //[self facebookRequestDidLoad:result];
                                     if (needToSelectHomeGroup) {
                                         // load home group page
                                         [self loadHomeGroupSelect];
                                     } else {
                                         //switch to main view
                                         [self switchToMainView];
                                     }
                                 }
                             }];
                             
                         }
                         else
                         {
                             //NSLog(@"This person already registered");
                             // Update the cache with their facebook friends
                             [self findFacebookFriends];
                             // This person already registered, update the user permission default for this device
                             [userDefaults setObject:permissionString forKey:@"sharePermission"];
                             [userDefaults setObject:fbLinkable forKey:@"FBLinkable"];
                             [userDefaults synchronize];
                             if (needToSelectHomeGroup) {
                                 // load home group page
                                 [self loadHomeGroupSelect];
                             } else {
                                 //switch to main view
                                 [self switchToMainView];
                             }
                         }
                         
                     }
                 }];
             }
             else
                 //Find out what went wrong
             {
                 NSLog(@"%@", error);
             }
         }];
    }
    else if (!userLinkedWithFacebook)
    {   // User logged in manually, find their current permission and fblinkable status
        //NSLog(@"The user logged in manually");
        
        PFQuery* userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            // this is a previously registered user
            if (object)
            {
                // Update the nsuser defaults
                NSString* permissionString = [object objectForKey:@"sharePermission"];
                NSString* fbLinkable = [object objectForKey:@"FbLinkable"];
                NSString* homeGroupName = [object objectForKey:@"group"];
                //NSLog(@"Permission = %@, Facebook linkable = %@, Home Group = %@", permissionString, fbLinkable, homeGroupName);
                [userDefaults setObject:permissionString forKey:@"sharePermission"];
                [userDefaults setObject:fbLinkable forKey:@"FBLinkable"];
                [userDefaults synchronize];
                if (homeGroupName != nil) {
                    needToSelectHomeGroup = false;
                    [userDefaults setObject:@"inGroup" forKey:@"HomeGroupSet"];
                    [userDefaults synchronize];
                } else {
                    //NSLog(@"Need to set home group");
                    needToSelectHomeGroup = true;
                }
                if (needToSelectHomeGroup) {
                    //NSLog(@"Loading Home Group");
                    // load home group page
                    [self loadHomeGroupSelect];
                } else {
                    //NSLog(@"Loading Main View");
                    //switch to main view
                    [self switchToMainView];
                }
            }
        }];
    }
}



-(void)loadHomeGroupSelect
{
    //NSLog(@"Loading test view from App Delegate");
    GroupRegionsViewController* regionsTVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupRegionsVC"];
    self.window.rootViewController = regionsTVC;
}

-(void)switchToMainView
{
    RootViewController* rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootView"];
    self.window.rootViewController = rootVC;
}

-(void)switchToLogInView
{
    // Create the log in screen, and set this as the delegate
    LogInViewController* logInVc = [[LogInViewController alloc] init];
    [logInVc setDelegate:self];
    
    // Add FACEBOOK Permissions and the fields for them
    logInVc.facebookPermissions = @[@"public_profile", @"email"];
    logInVc.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten;
    self.window.rootViewController = logInVc;
}

-(void)logOutUser
{
    // Clear created NSUserDefaults
    [userDefaults removeObjectForKey:@"sharePermission"];
    [userDefaults removeObjectForKey:@"FBLinkable"];
    [userDefaults removeObjectForKey:@"HomeGroupSet"];
    [userDefaults synchronize];
    
    // empty the cache
    [[Cache sharedCache] clear];
    
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:InstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    

    // Log out of parse
    [PFUser logOut];
    // Remove the stack
    //[self.navigationController popToRootViewControllerAnimated:NO];
    [self checkLogIn];
    // Move back to log in screen
    //AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //[appDelegate switchToLogInView];
    
    //UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UINavigationController* mainNavControl = [storyboard instantiateViewControllerWithIdentifier:@"launchNavController"];
    //[[UIApplication sharedApplication].keyWindow setRootViewController:mainNavControl];
}

// WHEN USER LOG IN FAILS
-(void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    // Find the error that was sent
    NSDictionary* errorDictionary = [error userInfo];
    // Get the error string
    NSString* errorString = [errorDictionary objectForKey:@"NSLocalizedDescription"];
    NSLog(@"The error is: %@", errorString);
    // Alert the user there was a problem logging in
    [[[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Email and Password are not valid. Please try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)handlePush:(NSDictionary *)launchOptions {
    
    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if (![PFUser currentUser]) {
            return;
        }
        
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:PushPayloadPhotoObjectIdKey];
        if (photoObjectId && photoObjectId.length > 0) {
            [self shouldNavigateToStory:[PFObject objectWithoutDataWithClassName:@"Testimonies" objectId:photoObjectId]];
            return;
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = [remoteNotificationPayload objectForKey:PushPayloadFromUserObjectIdKey];
        if (fromObjectId && fromObjectId.length > 0) {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                if (!error) {
                    // Display the main feed, the the profile view
                    RootViewController* rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootView"];
                    self.window.rootViewController = rootVC;
                    NSLog(@"Recieved push notification from app delegate, need to move to user view");
                   // UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
                   // self.tabBarController.selectedViewController = homeNavigationController;
                    
                   // PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
                   // accountViewController.user = (PFUser *)user;
                   // [homeNavigationController pushViewController:accountViewController animated:YES];
                }
            }];
        }
    }
}

- (void)shouldNavigateToStory:(PFObject *)targerStory {
   /* for (PFObject *photo in self.homeViewController.objects) {
        if ([photo.objectId isEqualToString:targetPhoto.objectId]) {
            targetPhoto = photo;
            break;
        }
    }
    
    // if we have a local copy of this photo, this won't result in a network fetch
    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:PAPHomeTabBarItemIndex];
            [self.tabBarController setSelectedViewController:homeNavigationController];
            
            PAPPhotoDetailsViewController *detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:object];
            [homeNavigationController pushViewController:detailViewController animated:YES];
        }
    }];*/
}
/*

// When the user wants to sync facebook data on the settings view
-(void)updateFacebookDataForUser:(PFUser*)user
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (!error)
         {
             // get the returned data
             NSLog(@"%@", result);
             facebookUserName = [result objectForKey:@"name"];
             facebookUserEmail = [[result objectForKey:@"email"] lowercaseString]; // For case insensitivity
             NSString* userId = [result objectForKey:@"id"];
             NSString* currentUserId = [user objectForKey:@"facebookId"];
             // make sure we have the right user
             if ([userId isEqualToString:currentUserId])
             {
                 // Update the remaining data
                 // get the user's current profile picture
                 NSURL* userProfilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",userId]];
                 // Make the request for the image with the timeout interval
                 NSURLRequest* profilePicURLRequest = [NSURLRequest requestWithURL:userProfilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
                 // Send the request
                 [NSURLConnection connectionWithRequest:profilePicURLRequest delegate:self];
                 // Use the NSURLConnectionDataDelegate to get the data
                 
                 user.email = facebookUserEmail;
                 [user setObject:facebookUserName forKey:@"UsersFullName"];
                 [user setObject:userId forKey:@"facebookId"];
                 [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if (error)
                     {
                         NSLog(@"%ld", (long)error.code);
                     }
                     else if (succeeded)
                     {
                         NSLog(@"User data was updated");
                     }
                 }];
             }
         }
         else
         {
             //Find out what went wrong
             NSLog(@"%@", error);
         }
     }];    
}
*/
-(void)findFacebookFriends {
    //NSLog(@"Finding Users Facebook friends");
    // Issue a Facebook Graph API request to get your user's friend list
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            //NSLog(@"facebook friends in cache: %@", friendObjects.description);
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            // cache friend data
            [[Cache sharedCache] setFacebookFriends:friendIds];
        }
    }];
}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)monitorReachability {
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
    
    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    [hostReach startNotifier];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
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
    [DataHelper saveFacebookImageData:facebookUserProfilePictureData];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Facebook callback
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
