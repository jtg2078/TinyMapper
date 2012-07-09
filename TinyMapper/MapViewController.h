//
//  MapViewController.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/25/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppManager.h"
#import "LocationAnnotation.h"
#import "Entry.h"

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *myMapView;
@property (nonatomic, weak) AppManager *manager;

@property (strong, nonatomic) Entry *entry;
@property (strong, nonatomic) NSNumber *lat;
@property (strong, nonatomic) NSNumber *lng;
@property (strong, nonatomic) LocationAnnotation *currentAnnotation;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSString *locationAddress;
@property (strong, nonatomic) NSArray *entries;
@property (strong, nonatomic) NSMutableArray *annotations;

- (void)updateAndDisplay;
- (void)updateAndDisplayMultipleEntries;

@end
