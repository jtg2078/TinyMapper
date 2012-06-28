//
//  OAuthWebViewController.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/26/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "OAuthWebViewController.h"

@interface OAuthWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *mainWebView;
@property (nonatomic, strong) NSURL *URL;

@end

@implementation OAuthWebViewController

@synthesize barsTintColor;
@synthesize URL;
@synthesize mainWebView;
@synthesize authDelegate;

#pragma mark - Initialization

- (id)initWithAddress:(NSString *)urlString 
{
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL*)pageURL 
{
    if(self = [super init]) 
    {
        self.URL = pageURL;
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)loadView 
{
    mainWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mainWebView.delegate = self;
    mainWebView.scalesPageToFit = YES;
    [mainWebView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    self.view = mainWebView;
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    mainWebView = nil;
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSString *webPageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if([self.authDelegate respondsToSelector:@selector(receivedTitle:)])
    {
        [self.authDelegate receivedTitle:webPageTitle];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Target actions

- (void)doneButtonClicked:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
