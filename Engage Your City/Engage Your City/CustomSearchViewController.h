//
//  CustomSearchViewController.h
//  Engage Your City
//
//  Created by Angela Smith on 2/25/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomSearchDelegate <NSObject>

- (void)viewController:(UIViewController *)viewController returnSearchString:(NSString*)searchString;

@end


@interface CustomSearchViewController : UIViewController {
    
    IBOutlet UIButton* cancelButton;
    
}

@property (nonatomic, assign) BOOL showStatusBar;
@property (nonatomic, strong) IBOutlet UITextField* searchField;
@property (nonatomic, strong) NSString* searchString;
@property (nonatomic, weak) id <CustomSearchDelegate> delegate;
@end
