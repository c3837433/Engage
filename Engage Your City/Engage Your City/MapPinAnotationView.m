//
//  MapPinAnotationView.m
//  Engage Your City
//
//  Created by Angela Smith on 3/18/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "MapPinAnotationView.h"

@implementation MapPinAnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.draggable = NO;
        self.canShowCallout = YES;
    }
    
    return self;
}


@end
