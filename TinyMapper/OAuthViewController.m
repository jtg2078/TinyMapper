//
//  OAuthViewController.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/26/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "OAuthViewController.h"
#import "OAuthWebViewController.h"

@interface OAuthViewController () <OAuthWebViewControllerDelegate>

@property (nonatomic, strong) OAuthWebViewController *webViewController;

@end

@implementation OAuthViewController

@synthesize webViewController;
@synthesize authDelegate;

- (id)initWithAddress:(NSString*)urlString 
{
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL *)URL 
{
    self.webViewController = [[OAuthWebViewController alloc] initWithURL:URL];
    if (self = [super initWithRootViewController:self.webViewController]) 
    {
        self.webViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:webViewController action:@selector(doneButtonClicked:)];
        self.webViewController.authDelegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - OAuthWebViewControllerDelegate

- (void)receivedTitle:(NSString *)title
{
    NSRange range = [title rangeOfString:@"Success code="];
    
    if(range.location == NSNotFound)
        return;
    
    NSString *authToken = [title substringFromIndex:range.location + range.length];
    
    if([self.authDelegate respondsToSelector:@selector(receivedAuthToken:)])
    {
        [self.authDelegate receivedAuthToken:authToken];
        
        [self.webViewController performSelector:@selector(doneButtonClicked:)];
    }
}

@end
