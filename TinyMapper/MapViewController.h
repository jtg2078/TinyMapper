//
//  MapViewController.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/25/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "APIManager.h"
#import "LocationAnnotation.h"

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *myMapView;
@property (strong, nonatomic) APIManager *apiManager;

@property (strong, nonatomic) NSNumber *lat;
@property (strong, nonatomic) NSNumber *lng;
@property (strong, nonatomic) LocationAnnotation *currentAnnotation;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSString *locationAddress;

- (void)updateAndDisplay;

@end
