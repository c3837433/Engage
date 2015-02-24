//
//  HomeGroupObject.m
//  Engage
//
//  Created by Angela Smith on 7/14/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "HomeGroupObject.h"

@implementation HomeGroupObject
@synthesize groupLeaders, groupAddress, groupCity, groupMeetDate, groupMeetTime, groupID;

-(id)initGroupObject:(NSString*)city leader:(NSString*)leader address:(NSString*)address date:(NSString*)date time:(NSString*)time gId:(NSString *)gId
{
    // Ititialize this as an object
    if ((self = [super init]))
    {
        // Save the data once it is pulled in
        groupMeetTime = [time copy];
        groupLeaders = [leader copy];
        groupMeetDate = [date copy];
        groupAddress = [address copy];
        groupCity = [city copy];
        groupID = [gId copy];
    }
    return self;
}
@end
