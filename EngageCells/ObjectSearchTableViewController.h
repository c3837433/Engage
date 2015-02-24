//
//  ObjectSearchTableViewController.h
//  EngageCells
//
//  Created by Angela Smith on 2/23/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjectSearchTableViewController : UITableViewController 

@property (nonatomic, strong) NSMutableArray* tagArray;
//@property (nonatomic, strong) NSMutableArray* uniqueObjectArray;
@property (strong, nonatomic) NSArray *filteredList;
@property (strong, nonatomic) UISearchController *searchController;

@end
