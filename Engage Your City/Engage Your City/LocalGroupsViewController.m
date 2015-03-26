//
//  LocalGroupsViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 3/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "LocalGroupsViewController.h"
#import "ApplicationKeys.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "LocalGroupCell.h"
#import "MapPinAnnotation.h"
#import "MapPinAnotationView.h"
#import "GroupDetailViewController.h"

@interface LocalGroupsViewController () {

    BOOL haveLocation;

}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) BOOL mapPannedSinceLocationUpdate;

@end

@implementation LocalGroupsViewController


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithStyle:UITableViewStylePlain];
    //self = [super initWithClassName:aHomeGroupClass];
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = aHomeGroupClass;
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of user stories to show per page
        self.objectsPerPage = 10;
        // listen for filter changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceFilterDidChange:) name:LocalFilterDistanceDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark Dealloc

- (void)dealloc {
    // start updates
    [_locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LocalFilterDistanceDidChangeNotification object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    haveLocation = false;
    // check if location services are enabled
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Check for iOS 8
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.mapView.showsUserLocation = YES;
    // set up the map location
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.332495f, -122.029095f),
                                                 MKCoordinateSpanMake(0.008516f, 0.021801f));
    self.mapPannedSinceLocationUpdate = NO;
    // set the delegate for the annotations
    [self.mapView setDelegate:self];
    
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%@", [locations lastObject]);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    [self.locationManager startUpdatingLocation];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
   
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable {
    // And set the query to look by location
    NSLog(@"Current location %@", self.currentLocation.description);
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:LocalFilterDistanceKey];
    [query whereKeyExists:aHomeGroupGeoLocation];
    [query whereKey:aHomeGroupJoinable equalTo:@"YES"];
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude
                                               longitude:self.currentLocation.coordinate.longitude];
    [query whereKey:aHomeGroupGeoLocation nearGeoPoint:point withinKilometers:ConvertMetersToKilometers(filterDistance)];
    
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return query;
}

#pragma mark - UITABLEVIEW DELEGATE AND DATA SOURCE METHODS
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    // see if there is an image
    if (indexPath.row == self.objects.count) {
        UITableViewCell* cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    else {
        // Get the group for this cell
        self.currentGroup = self.objects[indexPath.row];
        LocalGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"localGroupCell"];
        if (cell != nil) {
            [cell setUpGroup:self.currentGroup];
            NSString* listNumber = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
            cell.listNumberLabel.text = listNumber;
        }
       // NSLog(@"creating the anotation");
        // Add the pin to the map
        MapPinAnnotation *placePoint = [MapPinAnnotation annotationWithGroup:self.currentGroup];
        // Set the list number to corespond with the pin number
        NSString* listNumber = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
        placePoint.itemKey = listNumber;
        
        // Add the pin to the view
        [self.mapView addAnnotation:placePoint];
        return cell;
    
    }
}

static double ConvertMetersToKilometers(double meters) {
    return meters / 1000.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    // Get and return the load more cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.objects.count) {
        return 45;
    }
    return 85;
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    //NSLog(@"checking annotation class");
    if([annotation isKindOfClass:[MapPinAnnotation class]]) {
       // NSLog(@"Annotaion is a MapPinAnnotation");
        // Create the annotation
        MapPinAnnotation *annotationObject = (MapPinAnnotation*)annotation;
        if(annotationObject) {
            ///NSLog(@"We have an annotation object");
            NSString* pinIdent = @"groupPin";
            
            MapPinAnotationView* annotationView = [[MapPinAnotationView alloc] initWithAnnotation:annotationObject reuseIdentifier:pinIdent];
            
            // Background image
            UIImage *bgImage = [UIImage imageNamed:@"mapPin"];
            
            annotationView.frame = CGRectMake(0.0f, 0.0f, bgImage.size.width, bgImage.size.height);
            
            if(!annotationView.imageView) {
                annotationView.imageView = [UIImageView new];
                [annotationView addSubview:annotationView.imageView];
            }
            
            annotationView.imageView.backgroundColor = [UIColor clearColor];
            annotationView.imageView.frame=  CGRectMake(0.0f, 0.0f, annotationView.frame.size.width, annotationView.frame.size.height);
            [annotationView.imageView setImage:bgImage];
            
            annotationView.centerOffset = CGPointMake(0.0f, -(bgImage.size.height/2.0f));
            annotationView.backgroundColor=[UIColor clearColor];

            
            // Center label            
            if(!annotationView.centerLabel)
            {
                annotationView.centerLabel = [UILabel new];
                [annotationView addSubview:annotationView.centerLabel];
            }
            
            
            NSString * centerText = annotationObject.itemKey;
            
            annotationView.centerLabel.backgroundColor = [UIColor clearColor];
            annotationView.centerLabel.textColor = [UIColor whiteColor];
            annotationView.centerLabel.font = [UIFont boldSystemFontOfSize:10.0f];
            annotationView.centerLabel.textAlignment = NSTextAlignmentCenter;
            
            NSDictionary *attributes = @{NSFontAttributeName: annotationView.centerLabel.font};
            CGRect rect = [centerText boundingRectWithSize:CGSizeMake(annotationView.frame.size.width, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil];
            
            annotationView.centerLabel.frame = CGRectMake(0.0f, 4.0f, annotationView.frame.size.width, rect.size.height);
            
            annotationView.centerLabel.text = centerText;
           // NSLog(@"returning annotation view");
            return annotationView;
        }
    }
  //  NSLog(@"returning nothing");
    return nil;
}


#pragma mark -
#pragma mark CLLocationManagerDelegate methods and helpers

- (CLLocationManager *)locationManager {
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        else {
            _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
            
            [_locationManager startUpdatingLocation];
            
            //<<PUT YOUR CODE HERE AFTER LOCATION IS UPDATING>>    }
        }
    }
    return _locationManager;
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied:
            NSLog(@"kCLAuthorizationStatusDenied");
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Not Enabled" message:@"The app can’t access your current location.\n\nTo enable, please turn on location access in the Settings app under Location Services." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
            [_locationManager startUpdatingLocation];
            
            self.currentLocation = _locationManager.location;
            if (self.currentLocation != nil) {
                NSLog(@"We have a connection");
                if (!haveLocation) {
                    haveLocation = true;
                    [self loadObjects];
                }
            }
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
            [_locationManager startUpdatingLocation];
            
            self.currentLocation = _locationManager.location;
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"kCLAuthorizationStatusNotDetermined");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"kCLAuthorizationStatusRestricted");
            break;
    }
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.currentLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Error: %@", [error description]);
    
    if (error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
    } else if (error.code == kCLErrorLocationUnknown) {
        // todo: retry?
        // set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

#pragma mark NSNotificationCenter notification handlers

- (void)distanceFilterDidChange:(NSNotification *)note {
    // If they panned the map since our last location update, don't recenter it.
    if (!self.mapPannedSinceLocationUpdate) {
        // Set the map's region centered on their location at 2x filterDistance
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate,[self getMilesToMeters:15.0], [self getMilesToMeters:15.0]);
        [self.mapView setRegion:newRegion animated:YES];
        self.mapPannedSinceLocationUpdate = NO;
    } else {
        // Just zoom to the new search radius (or maybe don't even do that?)
        MKCoordinateRegion currentRegion = self.mapView.region;
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(currentRegion.center,[self getMilesToMeters:15.0], [self getMilesToMeters:15.0]);
        BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
        [self.mapView setRegion:newRegion animated:YES];
        self.mapPannedSinceLocationUpdate = oldMapPannedValue;
    }
}

- (void)setCurrentLocation:(CLLocation *)currentLocation {
    if (self.currentLocation == currentLocation) {
        return;
    }
    
    _currentLocation = currentLocation;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LocalCurrentLocationDidChangeNotification
                                                            object:nil
                                                          userInfo:@{ LocalLocationKey : currentLocation } ];
    });
    
    // If they panned the map since our last location update, don't recenter it.
    if (!self.mapPannedSinceLocationUpdate) {
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate,[self getMilesToMeters:15.0], [self getMilesToMeters:15.0]);
        
        
        BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
        [self.mapView setRegion:newRegion animated:YES];
        self.mapPannedSinceLocationUpdate = oldMapPannedValue;
    } // else do nothing.
    /*
    // Update the map with new pins:
    [self queryForAllPostsNearLocation:self.currentLocation withNearbyDistance:filterDistance];
    // And update the existing pins to reflect any changes in filter distance:
    [self updatePostsForLocation:self.currentLocation withNearbyDistance:filterDistance];*/
}

-(float) getMilesToMeters:(float) miles {
    // 1 mile is 1609.344 meters
    return 1609.344f * miles;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.row == self.objects.count) {
        [self loadNextPage];
    } else {
        PFObject* selectedGroup = [self.objects objectAtIndex:indexPath.row];
        GroupDetailViewController* groupDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"groupDetailVC"];
        groupDetailVC.group = selectedGroup;
        [self.navigationController pushViewController:groupDetailVC animated:YES];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
