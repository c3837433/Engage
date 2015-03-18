//
//  PostTableViewController.h
//  EngageCells
//
//  Created by Angela Smith on 2/15/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DZNSegmentedControl.h"
#import <ParseUI/ParseUI.h>
#import "PostTextCell.h"
#import "MZFormSheetController.h"
#import "CustomAddPostViewController.h"


@interface PostTableViewController : PFQueryTableViewController <DZNSegmentedControlDelegate, PostTextCellDelegate, UIActionSheetDelegate, MZFormSheetBackgroundWindowDelegate, CustomAddPostDelegate>
{

    UIBarButtonItem* searchBtn;
}

@property (nonatomic, strong) NSMutableDictionary* activityQueries;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* actionButton;
@property (nonatomic, strong) DZNSegmentedControl* segmentedControl;
@property (nonatomic, strong) NSArray* controlItems;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* addBtn;
/*
#define aPostText @"story"
#define aFont @"AvenirNext-Regular"
#define _allowAppearance    YES
#define _bakgroundColor     [UIColor colorWithRed:0/255.0 green:87/255.0 blue:173/255.0 alpha:1.0]
#define _tintColor          [UIColor colorWithRed:20/255.0 green:200/255.0 blue:255/255.0 alpha:1.0]
#define _hairlineColor      [UIColor colorWithRed:0/255.0 green:36/255.0 blue:100/255.0 alpha:1.0]
*/
@end
