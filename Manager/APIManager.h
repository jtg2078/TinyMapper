//
//  APIManager.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/25/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPClient;
@class AFOAuth2Client;
@interface APIManager : NSObject
{
    
}

@property (strong, nonatomic) AFOAuth2Client    * oAuthClient;
@property (strong, nonatomic) AFHTTPClient      * httpClient;

- (void)test;
- (NSString *)constructOAuthURLString;
- (void)setAuthToken:(NSString *)authToken;

- (void)saveAuthToken:(NSString *)authToken;
- (NSString *)loadAuthToken;
- (BOOL)hasAuthToken;

@end
