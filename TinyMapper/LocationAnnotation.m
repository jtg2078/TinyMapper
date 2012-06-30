//
//  LocationAnnotation.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/30/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "LocationAnnotation.h"

@implementation LocationAnnotation

#pragma mark - define

@synthesize name;
@synthesize address;
@synthesize lat;
@synthesize lng;

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = lat.doubleValue;
    theCoordinate.longitude = lng.doubleValue;
    return theCoordinate; 
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.address;
}

@end
