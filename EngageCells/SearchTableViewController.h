//
//  SearchTableViewController.h
//  EngageCells
//
//  Created by Angela Smith on 2/20/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
@interface SearchTableViewController : PFQueryTableViewController <UISearchBarDelegate, UISearchResultsUpdating>


@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) NSMutableArray *tagArray;



@end
