//
//  LogInViewController.h
//  Engage
//
//  Created by Angela Smith on 8/4/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface LogInViewController : UIViewController <UITextFieldDelegate>


@property (nonatomic, strong) IBOutlet UITextField* emailField;
@property (nonatomic, strong) IBOutlet UITextField* passwordField;

@end
