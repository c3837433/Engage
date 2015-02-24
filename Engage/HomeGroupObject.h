//
//  HomeGroupObject.h
//  Engage
//
//  Created by Angela Smith on 7/14/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeGroupObject : NSObject
{
    NSString* groupCity;
    NSString* groupLeaders;
    NSString* groupAddress;
    NSString* groupMeetDate;
    NSString* groupMeetTime;
    NSString* groupID;
}
// Properties for custom init
@property (nonatomic, readonly) NSString* groupCity;
@property (nonatomic, readonly) NSString* groupLeaders;
@property (nonatomic, readonly) NSString* groupAddress;
@property (nonatomic, readonly) NSString* groupMeetDate;
@property (nonatomic, readonly) NSString* groupMeetTime;
@property (nonatomic, readonly) NSString* groupID;


// Create a custom init method that will create the objects
-(id)initGroupObject:(NSString*)city leader:(NSString*)leader address:(NSString*)address date:(NSString*)date time:(NSString*)time gId:(NSString*)gId;

@end
