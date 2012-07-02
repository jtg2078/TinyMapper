//
//  APIManager.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/25/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GData.h"

@class AFHTTPClient;
@class AFOAuth2Client;
@class GTMOAuth2Authentication;
@interface APIManager : NSObject
{
    
}

@property (strong, nonatomic) AFOAuth2Client    * oAuthClient;
@property (strong, nonatomic) AFHTTPClient      * httpClient;

@property (strong, nonatomic) GDataServiceGoogleSpreadsheet *spreadsheetService;

@property (strong, nonatomic, readonly) NSString * clientID;
@property (strong, nonatomic, readonly) NSString * clientSecret;
@property (strong, nonatomic, readonly) NSString * clientScope;
@property (strong, nonatomic, readonly) NSString * clientKeyChainKey;

@property (nonatomic, strong) GTMOAuth2Authentication *authObj;

- (void)test;
- (NSString *)constructOAuthURLString;
- (void)setAuthToken:(NSString *)authToken;

- (void)saveAuthToken:(NSString *)authToken;
- (NSString *)loadAuthToken;
- (BOOL)hasAuthToken;

- (void)performAuthentication;

@end
