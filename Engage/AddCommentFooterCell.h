//
//  AddCommentFooterCell.h
//  Engage
//
//  Created by Angela Smith on 7/18/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>



@interface AddCommentFooterCell : PFTableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField* commentField;

@end

