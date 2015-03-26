//
//  MapPinAnnotation.m
//  Engage Your City
//
//  Created by Angela Smith on 3/18/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "MapPinAnnotation.h"
#import "ApplicationKeys.h"

@implementation MapPinAnnotation


#pragma mark - Lifecycle

- (id)initWithGroup:(PFObject *)group {
    self = [super init];
    if (self) {
        self.thisGroup = group;
        PFGeoPoint* pinPoint = [group objectForKey:aHomeGroupGeoLocation];
        self.coordinate = CLLocationCoordinate2DMake(pinPoint.latitude, pinPoint.longitude);
        self.title = [group objectForKey:aHomeGroupLeader];
        self.subtitle = [group objectForKey:aHomeGroupMeetDate];
    }
    
    return self;
}

#pragma mark - Class

+ (id)annotationWithGroup:(PFObject *)group {
    MapPinAnnotation* pin = [MapPinAnnotation new];
    
    pin.thisGroup = group;
    PFGeoPoint* pinPoint = [group objectForKey:aHomeGroupGeoLocation];
    pin.coordinate = CLLocationCoordinate2DMake(pinPoint.latitude, pinPoint.longitude);
    pin.title = [group objectForKey:aHomeGroupLeader];
    pin.subtitle = [group objectForKey:aHomeGroupMeetDate];
    
    return pin;
}

@end
