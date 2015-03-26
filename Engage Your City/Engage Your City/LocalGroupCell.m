//
//  LocalGroupCell.m
//  Engage Your City
//
//  Created by Angela Smith on 3/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "LocalGroupCell.h"
#import "ApplicationKeys.h"
#import <Parse/Parse.h>

@implementation LocalGroupCell

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;
    
    // Your code goes here!
    
    return self;
}

-(void) setUpGroup:(PFObject*)group {

    self.thisGroup = group;
    self.groupLeaderLabel.text = [self.thisGroup objectForKey:aHomeGroupLeader];
    self.groupLocationLabel.text = [self.thisGroup objectForKey:aHomeGroupCity];
    NSString* meetDate = @"";
    NSString* meetTime = @"";
    if ([self.thisGroup objectForKey:aHomeGroupMeetDate]) {
        meetDate = [self.thisGroup objectForKey:aHomeGroupMeetDate];
    }
    if ([self.thisGroup objectForKey:aHomeGroupMeetTime]) {
        meetTime = [self.thisGroup objectForKey:aHomeGroupMeetTime];
    }
    NSString* meetString;
    if (![meetDate isEqualToString:@""]) {
        if (![meetTime isEqualToString:@""]) {
            meetString = [NSString stringWithFormat:@"%@ at %@", meetDate, meetTime];
        } else {
            meetString = meetDate;
        }
        
    } // Date is empty, check time
    else if (![meetTime isEqualToString:@""]) {
        meetString = [NSString stringWithFormat:@"Meets at %@", meetTime];
    } else {
        meetString = @"To be determined.";
    }
    self.groupMeetLabel.text = meetString;
}

@end
