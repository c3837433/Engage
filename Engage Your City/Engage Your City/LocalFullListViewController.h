//
//  LocalFullListViewController.h
//  Engage Your City
//
//  Created by Angela Smith on 3/26/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@interface LocalFullListViewController : PFQueryTableViewController

@property (nonatomic, strong) NSString* searchTerm;
// If the user needs to browse verses find a group with a search term
@property (nonatomic) BOOL searchList;

@property (nonatomic, strong) PFObject* regionObject;
@end
