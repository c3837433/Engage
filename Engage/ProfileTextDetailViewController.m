//
//  ProfileTextDetailViewController.m
//  Engage
//
//  Created by Angela Smith on 8/16/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "ProfileTextDetailViewController.h"
#import "Utility.h"

@interface ProfileTextDetailViewController ()

@end

@implementation ProfileTextDetailViewController
@synthesize selectedObject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // Add background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBg"]];
    
    // Set the text in the labels
    storyTitleLabel.text = [selectedObject objectForKey:@"title"];
    storyTextLabel.text = [selectedObject objectForKey:@"story"];
    
    // Set the time since story was created
    NSDate* timeCreated = selectedObject.createdAt;
    // Set the time interval
    //NSTimeInterval timeInterval = [timeCreated timeIntervalSinceNow];
    // Get a formatter
    //TTTTimeIntervalFormatter* timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
    // Create a string of the time since crated
    //NSString* timeSinceCreatedString = [timeFormatter stringForTimeInterval:timeInterval];
    Utility* utility = [[Utility alloc] init];
    NSString* timestamp = [utility stringForTimeIntervalSinceCreated:timeCreated];
    timeStampSinceCreationLabel.text = timestamp;
    // Set the string
    //timeStampSinceCreationLabel.text = timeSinceCreatedString;
    
    // Change the uiview background by adding corners, border and shadow to match the Engage view
    // Corners and Border
    storyView.layer.cornerRadius = 8.0f;
    [storyView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [storyView.layer setBorderWidth:0.3f];
    // Shadow
    [storyView.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [storyView.layer setShadowOpacity:0.8];
    [storyView.layer setShadowRadius:0.8];
    [storyView.layer setShadowOffset:CGSizeMake(0.8, 0.8)];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
