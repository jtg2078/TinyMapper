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

@implementation APIManager

#pragma mark - define

#define OAUTH_URL               @"https://accounts.google.com/o/oauth2/auth"
#define GOOGLE_DOC_API_URL      @""
#define GOOGLE_CLIENT_ID        @"1073301038679.apps.googleusercontent.com"
#define GOOGLE_CLIENT_SECRET    @"2hkmbNDVbShCqnKL5BJXlOc8"

#define USER_DEFAULT_AUTH_TOKEN_KEY     @"authTokenKey"

#pragma mark - synthesize

@synthesize oAuthClient;
@synthesize httpClient;

#pragma mark - dealloc

#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        
        oAuthClient = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:OAUTH_URL]];
        [oAuthClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
        httpClient = [[AFHTTPClient alloc] initWithBaseURL:nil];
        
        if([self hasAuthToken])
        {
            [httpClient setAuthorizationHeaderWithToken:[self loadAuthToken]];
        }
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
