//
//  FindStoriesViewController.h
//  Engage
//
//  Created by Angela Smith on 2/19/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface FindStoriesViewController : UITableViewController

{
    IBOutlet UISearchBar* searchBar;
}
@property (nonatomic, strong) NSMutableArray* tagArray;
@property (strong, nonatomic) NSArray *filteredList;


@end
