//
//  SearchableTableview.m
//  EngageCells
//
//  Created by Angela Smith on 2/19/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "SearchableTableview.h"
#import <Parse/Parse.h> 
#import "Utility.h"
#import "Cache.h"
#import "PostTextCell.h"
#import "PostImageCell.h"
#import <QuartzCore/QuartzCore.h>


@interface SearchableTableview () <UISearchBarDelegate, UISearchControllerDelegate>

@property (nonatomic, strong) NSArray *tagArray;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* actionButton;
@property (nonatomic, strong) NSString* seletedHashtag;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchableTableview

@synthesize actionButton;

#pragma mark - Parse Methods
// Storyboard init
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithStyle:UITableViewStylePlain];
    self = [super initWithClassName:@"Testimonies"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = @"Testimonies";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of user stories to show per page
        self.objectsPerPage = 5;
    }
    return self;
}

// Search parse for Stories to be displayed withing the table
- (PFQuery *)queryForTable {
    if ((self.seletedHashtag == nil) || ([self.seletedHashtag isEqualToString:@""])) {
        // do not return anything
        NSLog(@"No hashtag set");
        PFQuery *query = nil;
        NSError* error = [[NSError alloc] init];
        [super objectsDidLoad:error];
        return query;
    } else {
        //
        NSLog(@"Hashtag set");
        PFQuery *hashtagQuery = [PFQuery queryWithClassName:@"Hashtags"];
        // [hashtagQuery includeKey:@"Story"];
        [hashtagQuery whereKey:@"tag" equalTo:self.seletedHashtag];
        NSLog(@"The selected hashtag: %@", self.seletedHashtag);
        
        PFQuery* storyQuery = [PFQuery queryWithClassName:@"Testimonies"];
        [storyQuery whereKey:@"objectId" matchesKey:@"PointerString" inQuery:hashtagQuery];
        [storyQuery includeKey:@"author"];
        [storyQuery includeKey:@"Group"];
        [storyQuery orderByDescending:@"createdAt"];
        // remove any stories that are flagged
        [storyQuery whereKeyDoesNotExist:@"Flagged"];
        
        // If there is no network connection, we will hit the cache first.
        if (self.objects.count == 0) {//|| ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
            [storyQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
        }
        return storyQuery;
    }
}
-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

}
- (void)viewDidLoad
{
    // get tags
    PFQuery* tagQuery = [PFQuery queryWithClassName:@"Hashtags"];
    [tagQuery whereKeyExists:@"tag"];
   // [tagQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [tagQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            NSMutableArray* allTagsArray = [[NSMutableArray alloc] init];
            for (PFObject* object in objects) {
                // get the tag
                NSString* tag = [object objectForKey:@"tag"];
                [allTagsArray addObject:tag];
              //  if (![allTagsArray containsObject:tag]) {
             //       [allTagsArray addObject:tag];
              //  }
            }
            // send the array to get items and counts
            [self getTagsAndCounts:allTagsArray];
           // _tagArray =  allTagsArray;
           // NSLog(@"Tags found %@", _tagArray.description);
        }
    }];

    NSLog(@"Tags found after %@", _tagArray.description);
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Add background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBg"]];
    self.tableView.estimatedRowHeight = 180;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}


// Reload the table when returning from comment view
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITABLEVIEW DELEGATE
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    
    // check the tableview again
    if (tableView == self.tableView) {
        // Get the saying for this cell
        PFObject* saying = self.objects[indexPath.row];
        // see if there is an image
        if (indexPath.row == self.objects.count)
        {
            UITableViewCell* cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
            return cell;
        }
        else if ([[saying objectForKey:@"media"] isEqual:@"text"]) {
            // set the post cell
            // Create a testing cell InSetPostTextCell  PostTextCell
            PostTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InSetPostTextCell"];
            if (cell != nil) {
                
                // Set the saying to the cell
                PFObject* saying = self.objects[indexPath.row];
                [cell setPost:saying];
                
                // set up hashtags
                [cell.postStoryLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                    NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
                    
                    // NSString* selection = [NSString stringWithFormat:@"%@ [%d,%d]: %@%@", hotWords[hotWord], (int)range.location, (int)range.length, string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
                    //NSLog(@"%@", selection);
                    
                    NSString* selectedHotWord = [NSString stringWithFormat:@"%@", hotWords[hotWord]];
                    NSString* word = [NSString stringWithFormat:@"%@%@", string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
                    
                    [self alertUserWithSelection:selectedHotWord word:word];
                    
                }];
            }
            return cell;
        } else {
            // set the image cell  InSetPostMediaCell PostImageCell
            PostImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InSetPostMediaCell"];
            if (cell != nil) {
                // set the story
                [cell setPost:saying];
                // and the image
                [cell setPostImageFrom:saying];
                // and up hashtags
                [cell.postStoryLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                    NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
                    
                    // NSString* selection = [NSString stringWithFormat:@"%@ [%d,%d]: %@%@", hotWords[hotWord], (int)range.location, (int)range.length, string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
                    //NSLog(@"%@", selection);
                    
                    NSString* selectedHotWord = [NSString stringWithFormat:@"%@", hotWords[hotWord]];
                    NSString* word = [NSString stringWithFormat:@"%@%@", string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
                    
                    [self alertUserWithSelection:selectedHotWord word:word];
                    
                }];
            }
            return cell;
        }
    } else {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
        // search cells need to be instanciated
        if (!cell) {
            // instanciate it
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchCell"];
        }
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
        return cell;
    
    }

}
-(void)alertUserWithSelection:(NSString*)type word:(NSString*)word {
    NSString* alertTitle = [NSString stringWithFormat:@"You Tapped the %@", type];
    [[[UIAlertView alloc] initWithTitle:alertTitle message:word delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.objects.count;
    } else {
        return self.searchResults.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    // Get and return the load more cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}

-(void)getTagsAndCounts:(NSArray*) allTagsArray {
    NSMutableArray *tags;
    //  NSArray *names = [NSArray arrayWithObjects:@"John", @"Jane", @"John", nil];
    // created a counted set
    NSCountedSet *set = [[NSCountedSet alloc] initWithArray:allTagsArray];
    for (id item in set) {
        if (![allTagsArray containsObject:item]) {
            //       [allTagsArray addObject:tag];
            //  }
        NSMutableDictionary* tagDictionary = [[NSMutableDictionary alloc] init];
        int myInteger = (int)[set countForObject:item];
        [tagDictionary setObject:item forKey:@"tag"];
        [tagDictionary setObject:[NSNumber numberWithInt:myInteger] forKey:@"count"];
        }
    }
    
}


#pragma mark -  UISEARCHBAR
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    self.searchResults = nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@", self.searchBar.text];
    
    self.searchResults = [self.tagArray filteredArrayUsingPredicate:predicate];
}


@end
