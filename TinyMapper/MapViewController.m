//
//  MapViewController.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/25/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "MapViewController.h"
#import "OAuthViewController.h"

#import "GTMOAuth2ViewControllerTouch.h"
#import "APIManager.h"
#import "AppDelegate.h"

#import "MKMapView+ZoomLevel.h"


@interface MapViewController () <OAuthViewControllerDelegate>

@end

@implementation MapViewController

@synthesize myMapView;
@synthesize apiManager;
@synthesize lat;
@synthesize lng;
@synthesize currentAnnotation;
@synthesize locationName;
@synthesize locationAddress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"Front View", @"FrontView");
	
	if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] && [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
	{
		UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
		
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"列表", nil) 
                                                                                 style:UIBarButtonItemStylePlain 
                                                                                target:self.navigationController.parentViewController 
                                                                                action:@selector(revealToggle:)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"OAuth", nil) 
                                                                                  style:UIBarButtonItemStylePlain 
                                                                                 target:self 
                                                                                 action:@selector(loginGData)];
	}
    
    
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

- (void)login
{
    NSURL *URL = [NSURL URLWithString:[self.apiManager constructOAuthURLString]];
	
    OAuthViewController *webViewController = [[OAuthViewController alloc] initWithURL:URL];
	webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    webViewController.authDelegate = self;
	[self presentModalViewController:webViewController animated:YES];
}


- (void)loginGData
{
    // Do any additional setup after loading the view.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    APIManager *api = delegate.apiManager;
    
    [api performAuthentication];
}

- (void)updateAndDisplay
{
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

#pragma mark - OAuthViewControllerDelegate

- (void)receivedAuthToken:(NSString *)token
{
    NSLog(@"auth token: %@", token);
    [self.apiManager setAuthToken:token];
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
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
			
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

@end
