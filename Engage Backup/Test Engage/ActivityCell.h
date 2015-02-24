//
//  ActivityCell.h
//  Engage
//
//  Created by Angela Smith on 1/22/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//  Created by Mattieu Gamache-Asselin on 5/14/12.
//  Origionally Copyright (c) 2013 Parse. All rights reserved.

#import "BaseTableViewCell.h"

@protocol ActivityCellDelegate;

@interface ActivityCell : BaseTableViewCell


/*!Setter for the activity associated with this cell */
@property (nonatomic, strong) PFObject *activity;

/*!Set the new state. This changes the background of the cell. */
- (void)setIsNew:(BOOL)isNew;

@end


/*!
 The protocol defines methods a delegate of a PAPBaseTextCell should implement.
 */
@protocol ActivityCellDelegate <BaseTableViewCellDelegate>
@optional

/*!
 Sent to the delegate when the activity button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(ActivityCell *)cellView didTapActivityButton:(PFObject *)activity;

@end
