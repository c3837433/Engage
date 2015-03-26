//
//  LogInViewController.m
//  Engage
//
//  Created by Angela Smith on 8/4/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "LogInViewController.h"
#import "MySignUpViewController.h"
//#import "PanelViewController.h"
#import <ParseUI/ParseUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "AppDelegate.h"
#import "Cache.h"

@interface LogInViewController () {

     NSUserDefaults* userDefaults;
    // User Name and email
    NSString* facebookUserName;
    NSString* facebookUserEmail;

}

@end

@implementation LogInViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}


- (BOOL) shouldAutorotate {
    return NO;
}

// Background is light, change status bar to dark
- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
#pragma mark UITEXTFIELD DELEGATE
// Check the entered text
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == self.emailField)
    {
        // Convert the email to lowercase to match the stored parse username
        textField.text = [textField.text lowercaseString];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Move the user to the next fields when they hit enter
    if(textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    }
    else if (textField == self.passwordField) {
        [self.passwordField resignFirstResponder];
    }
    return NO;
}

- (IBAction)checkLogInCredentialsForLogIn:(id)sender {
    // Get the values in the text fields
    NSString* email = self.emailField.text;
    NSString* password = self.passwordField.text;
    if (([email isEqual:@""]) || ([password isEqual:@""])) {
        // Alert user we need both values
        [self alertUserWithTitle:@"Missing Info" message:@"Please make sure both fields are filled in."];
    } else {
        // Attempt to log user in
        [PFUser logInWithUsernameInBackground:email password:password
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                NSLog(@"User logged in");
                                                [self.navigationController popToRootViewControllerAnimated:NO];
                                                // Move back to log in screen
                                                AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                //[appDelegate switchToLogInView];
                                                [appDelegate didLogInUser:user];

                                            } else {
                                                if (error.code == 101) {
                                                    // Invalid Login credentials
                                                    [self alertUserWithTitle:@"Email or Password are Incorrect" message:@"Please try again."];
                                                } else {
                                                    // see what happened
                                                    NSLog(@"Error: %@", error.description);
                                                    [self alertUserWithTitle:@"Problem Logging In" message:@"Please try again."];
                                                }
                                            }
                                        }];
    }
}

-(IBAction)forgotPasswordResetSelected:(id)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Password Reset"
                                                                   message:@"Enter your Engage login email address to initiate the password reset."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = self.emailField.text;
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              // get entered text
                                                              UITextField* emailField = alert.textFields[0];
                                                              NSLog(@"entered email address: %@", emailField.text);
                                                              [self resetLoginPasswordWithEmail:emailField.text];
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                          }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:defaultAction];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

}

-(void) resetLoginPasswordWithEmail:(NSString*)email {
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
        [self alertUserPasswordConfirmation:succeeded];
    }];

}

-(void)alertUserPasswordConfirmation:(BOOL)succeeded {
    
    NSString* message = (succeeded) ? @"Email reset link was sent." : @"Unable to reset login for entered email.";
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)userLoggingInThroughFacebook:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"public_profile", @"email"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            [self.navigationController popToRootViewControllerAnimated:NO];
            // Move to main view
            AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate didLogInUser:user];
        }
    }];
}


-(void)alertUserWithTitle:(NSString*)title message:(NSString*)message {
    // Display alert to user
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
