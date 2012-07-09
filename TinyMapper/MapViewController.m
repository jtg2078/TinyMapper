//
//  MapViewController.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/25/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "MapViewController.h"

#import "APIManager.h"
#import "AppDelegate.h"

#import "MKMapView+ZoomLevel.h"
#import "SVProgressHUD.h"

#import "DetailViewController.h"

@implementation MapViewController

@synthesize myMapView;
@synthesize manager;
@synthesize lat;
@synthesize lng;
@synthesize currentAnnotation;
@synthesize locationName;
@synthesize locationAddress;
@synthesize entry;
@synthesize entries;
@synthesize annotations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"地圖", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
	if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] && 
        [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
	{
		UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
		
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"地點列表", nil) 
                                                                                 style:UIBarButtonItemStylePlain 
                                                                                target:self.navigationController.parentViewController 
                                                                                action:@selector(revealToggle:)];
	}
    
    self.manager = [AppManager sharedInstance];
    self.annotations = [NSMutableArray array];
}

- (void)viewDidUnload
{
    [self setMyMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - user interaction

- (void)loginGData
{
    [SVProgressHUD showWithStatus:@"uploading location to GAE"];
    [manager uploadLocationEntry:self.entry resultHandler:^(NSString *message, NSError *error) {
        [SVProgressHUD showSuccessWithStatus:message];
    }];
}

- (void)updateAndDisplay
{
    self.title = self.locationName;
    
    if(self.annotations.count)
    {
        [self.myMapView removeAnnotations:self.annotations];
        [self.annotations removeAllObjects];
    }
    
    if(self.currentAnnotation == nil)
    {
        currentAnnotation = [[LocationAnnotation alloc] init];
    }
    
    self.currentAnnotation.name = self.locationName;
    self.currentAnnotation.address = self.locationAddress;
    self.currentAnnotation.lat = self.lat;
    self.currentAnnotation.lng = self.lng;
    
    // setup initial region
    CLLocationCoordinate2D location;
    location.latitude = self.lat.doubleValue;
    location.longitude = self.lng.doubleValue;
    [self.myMapView setCenterCoordinate:location zoomLevel:15 animated:YES];
    
    [self.myMapView removeAnnotation:self.currentAnnotation];
    [self.myMapView addAnnotation:self.currentAnnotation];
}

- (void)updateAndDisplayMultipleEntries
{
    Entry *e = [self.entries lastObject];
    self.title = e.type;
    
    // reset parameters
    if(self.currentAnnotation)
    {
        [self.myMapView removeAnnotation:self.currentAnnotation];
    }
    
    if(self.annotations.count)
    {
        [self.myMapView removeAnnotations:self.annotations];
        [self.annotations removeAllObjects];
    }
    
    for(Entry *e in self.entries)
    {
        LocationAnnotation *annotation = [[LocationAnnotation alloc] init];
        annotation.name = e.name;
        annotation.address = e.address;
        annotation.lat = e.lat;
        annotation.lng = e.lon;
        annotation.entry = e;
        
        [self.annotations addObject:annotation];
    }
    
    // calculate the zoom rect
    
    MKMapPoint annotationPoint = MKMapPointForCoordinate([[self.annotations lastObject] coordinate]);
    if(self.myMapView.userLocation)
        annotationPoint = MKMapPointForCoordinate(self.myMapView.userLocation.coordinate);
    MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
    for (LocationAnnotation* annotation in self.annotations)
    {
        annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    
    [self.myMapView setVisibleMapRect:zoomRect animated:YES];
    
    
    // add annotaion to the map
    [self.myMapView addAnnotations:self.annotations];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
	if ([annotation isKindOfClass:[LocationAnnotation class]])
	{
		// try to dequeue an existing pin view first
        static NSString* ItemAnnotationIdentifier = @"itemAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[self.myMapView dequeueReusableAnnotationViewWithIdentifier:ItemAnnotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation 
                                                                                reuseIdentifier:ItemAnnotationIdentifier];
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            customPinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;		
	}
	
	return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    // so we are in multiple annotations mode, dont need to do auto map call out
    if(self.annotations.count)
        return;
    
    for (id<MKAnnotation> annotation in mapView.annotations) 
	{       
		if ([annotation isKindOfClass:[LocationAnnotation class]]) 
		{
			double delayInSeconds = 0.5;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [mapView selectAnnotation:annotation animated:NO];
            });
            break;
		}
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    DetailViewController *dvc = [[DetailViewController alloc] init];
    
    
    if(self.annotations.count)
    {
        LocationAnnotation *annotation = view.annotation;
        dvc.entry = annotation.entry;
    }
    else 
    {
        dvc.entry = self.entry;
    }
    
    UINavigationController *nav_dvc = [[UINavigationController alloc] initWithRootViewController:dvc];
    nav_dvc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:nav_dvc animated:YES];
}

@end
