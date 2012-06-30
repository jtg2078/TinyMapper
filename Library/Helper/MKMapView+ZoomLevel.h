//
//  MKMapView+ZoomLevel.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/30/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate 
                  zoomLevel:(NSUInteger)zoomLevel 
                   animated:(BOOL)animated;

@end 
