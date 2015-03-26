//
//  MapPinAnnotation.h
//  Engage Your City
//
//  Created by Angela Smith on 3/18/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface MapPinAnnotation : NSObject <MKAnnotation>


@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) PFObject* thisGroup;
@property (nonatomic, strong) NSString* itemKey;

- (id)initWithGroup:(PFObject *)group;
+ (id)annotationWithGroup:(PFObject *)group;

@end
