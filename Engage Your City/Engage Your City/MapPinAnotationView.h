//
//  MapPinAnotationView.h
//  Engage Your City
//
//  Created by Angela Smith on 3/18/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MapPinAnotationView : MKAnnotationView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *centerLabel;

@end
