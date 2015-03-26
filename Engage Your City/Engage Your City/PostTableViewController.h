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

@end
