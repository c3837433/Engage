//
//  LocalGroupsViewController.h
//  Engage Your City
//
//  Created by Angela Smith on 3/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocalGroupsViewController : PFQueryTableViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet MKMapView* mapView;
@property (nonatomic, strong) PFObject* currentGroup;

@end
