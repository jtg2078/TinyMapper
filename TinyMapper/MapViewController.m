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


@interface MapViewController () <OAuthViewControllerDelegate>

@end

@implementation MapViewController

@synthesize apiManager;

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
		
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reveal", @"Reveal") 
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
    
    GTMOAuth2ViewControllerTouch *ga2vc = [GTMOAuth2ViewControllerTouch controllerWithScope:api.clientScope 
                                                                                   clientID:api.clientID 
                                                                               clientSecret:api.clientSecret 
                                                                           keychainItemName:api.clientKeyChainKey 
                                                                          completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
                                                                              
                                                                              if(error == nil)
                                                                              {
                                                                                  api.authObj = auth;
                                                                              }
                                                                              else
                                                                              {
                                                                                  NSLog(@"failed");
                                                                              }
                                                                              [delegate dismissModalViewControllerAnimated:YES];
                                                                              
                                                                          }];
    [delegate presentModalViewController:ga2vc animated:YES];
    
    
    
}

#pragma mark - OAuthViewControllerDelegate

- (void)receivedAuthToken:(NSString *)token
{
    NSLog(@"auth token: %@", token);
    [self.apiManager setAuthToken:token];
}

@end
