//
//  APIManager.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/25/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "APIManager.h"
#import "AFOAuth2Client.h"
#import "AFNetworking.h"

#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "AppDelegate.h"
//#import "GDataServiceGoogleDocs.h"



@implementation APIManager

#pragma mark - define

#define OAUTH_URL               @"https://accounts.google.com/o/oauth2/auth"
#define GOOGLE_DOC_API_URL      @""
#define GOOGLE_CLIENT_ID        @"1073301038679.apps.googleusercontent.com"
#define GOOGLE_CLIENT_SECRET    @"2hkmbNDVbShCqnKL5BJXlOc8"

#define USER_DEFAULT_AUTH_TOKEN_KEY     @"authTokenKey"
#define GOOGLE_SCOPE            @"https://docs.google.com/feeds/ https://docs.googleusercontent.com/ https://spreadsheets.google.com/feeds/"

#pragma mark - synthesize

@synthesize oAuthClient;
@synthesize httpClient;
@synthesize authObj;

@synthesize clientID;
@synthesize clientSecret;
@synthesize clientScope;
@synthesize clientKeyChainKey;
@synthesize spreadSheetService;

#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        
        oAuthClient = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:OAUTH_URL]];
        [oAuthClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
        httpClient = [[AFHTTPClient alloc] initWithBaseURL:nil];
        
        clientID = GOOGLE_CLIENT_ID;
        clientSecret = GOOGLE_CLIENT_SECRET;
        clientScope = GOOGLE_SCOPE;
        clientKeyChainKey = USER_DEFAULT_AUTH_TOKEN_KEY;
    }
    return self;
}

#pragma mark - main methods

- (void)test
{
    [oAuthClient authenticateUsingOAuthWithPath:@"/o/oauth2/auth" 
                                       username:@"jtg2078@gmail.com" 
                                       password:@"jthegreat" 
                                       clientID:GOOGLE_CLIENT_ID 
                                         secret:GOOGLE_CLIENT_SECRET 
                                        success:^(AFOAuthAccount *account) {
        NSLog(@"Credentials: %@", account.credential.accessToken);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (NSString *)constructOAuthURLString
{
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    [p setObject:@"code" forKey:@"response_type"];
    [p setObject:GOOGLE_CLIENT_ID forKey:@"client_id"];
    [p setObject:@"urn:ietf:wg:oauth:2.0:oob" forKey:@"redirect_uri"];
    [p setObject:@"https://docs.google.com/feeds/ https://docs.googleusercontent.com/ https://spreadsheets.google.com/feeds/" forKey:@"scope"];
    
    NSString *url = AFQueryStringFromParametersWithEncoding(p, NSUTF8StringEncoding);
    
    return [NSString stringWithFormat:@"%@?%@", OAUTH_URL, url];
}

- (void)performAuthentication
{
    // Do any additional setup after loading the view.
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    GTMOAuth2ViewControllerTouch *ga2vc = [GTMOAuth2ViewControllerTouch controllerWithScope:self.clientScope 
                                                                                   clientID:self.clientID 
                                                                               clientSecret:self.clientSecret 
                                                                           keychainItemName:self.clientKeyChainKey 
                                                                          completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
                                                                              
                                                                              if(error == nil)
                                                                              {
                                                                                  self.authObj = auth;
                                                                              }
                                                                              else
                                                                              {
                                                                                  NSLog(@"failed");
                                                                              }
                                                                              [delegate dismissModalViewControllerAnimated:YES];
                                                                              
                                                                          }];
    [delegate presentModalViewController:ga2vc animated:YES];
     
}

- (void)testGoogleDoc
{
     if(self.spreadSheetService == nil)
     {
         spreadSheetService = [[GDataServiceGoogleSpreadsheet alloc] init];
         
         [self.spreadSheetService setShouldCacheResponseData:YES];
         [self.spreadSheetService setServiceShouldFollowNextLinks:YES];
         
         // username/password may change
         NSString *username = @"jtg2078@gmail.com";
         NSString *password = @"jthegreat";
         
         [self.spreadSheetService setUserCredentialsWithUsername:username
                                                        password:password];
     }
    
    NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
    [self.spreadSheetService fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        
    }];
}


#pragma mark - auth token management

- (void)setAuthToken:(NSString *)authToken
{
    [httpClient setAuthorizationHeaderWithToken:authToken];
    [self saveAuthToken:authToken];
}

- (void)saveAuthToken:(NSString *)authToken
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:authToken forKey:USER_DEFAULT_AUTH_TOKEN_KEY];
    [userDefault synchronize];
}

- (NSString *)loadAuthToken
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault stringForKey:USER_DEFAULT_AUTH_TOKEN_KEY];
}

- (BOOL)hasAuthToken
{
    if([[self loadAuthToken] length])
        return YES;
    
    return NO;
}



@end
