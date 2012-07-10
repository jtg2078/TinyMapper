//
//  GoogleGeocodingOperation.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/10/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "GoogleGeocodingOperation.h"
#import "AFJSONRequestOperation.h"

@implementation GoogleGeocodingOperation

/*
 "OK"   indicates that no errors occurred; the address was successfully parsed and at least one geocode was returned.
 "ZERO_RESULTS" indicates that the geocode was successful but returned no results. 
                This may occur if the geocode was passed a non-existent address or a latlng in a remote location.
 "OVER_QUERY_LIMIT" indicates that you are over your quota.
 "REQUEST_DENIED" indicates that your request was denied, generally because of lack of a sensor parameter.
 "INVALID_REQUEST" generally indicates that the query (address or latlng) is missing.
 */

#define GOOGLE_API_CODE_OK                      @"OK"
#define GOOGLE_API_CODE_ZERO_RESULTS            @"ZERO_RESULTS"
#define GOOGLE_API_CODE_OVER_QUERY_LIMIT        @"OVER_QUERY_LIMIT"
#define GOOGLE_API_CODE_REQUEST_DENIED          @"REQUEST_DENIED"
#define GOOGLE_API_CODE_INVALID_REQUEST         @"INVALID_REQUEST"

- (void)geocode
{
    [super geocode];
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", [self.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *status = [JSON objectForKey:@"status"];
        if([status isEqualToString:GOOGLE_API_CODE_OK] == YES)
        {
            NSDictionary *result = [[JSON objectForKey:@"results"] lastObject];
            NSDictionary *geometry = [result objectForKey:@"geometry"];
            NSDictionary *location = [geometry objectForKey:@"location"];
            NSNumber *lat = [location objectForKey:@"lat"];
            NSNumber *lng = [location objectForKey:@"lng"];
            NSString *formattedAddress = [result objectForKey:@"formatted_address"];
            
            self.message = @"GoogleGeocodingOperation completed successful";
            
            [self completeOperationResult:YES 
                                      lat:lat 
                                      lon:lng 
                         formattedAddress:formattedAddress];
        }
        else
        {
            self.message = [NSString stringWithFormat:@"Google Map API 無法解析地址: %@", status];
            
            [self completeOperationResult:NO 
                                      lat:nil 
                                      lon:nil 
                         formattedAddress:nil];
            
        }
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        self.message = @"無法連線到Google Map API";
        [self completeOperationResult:NO 
                                  lat:nil 
                                  lon:nil 
                     formattedAddress:nil];
    }];
    
    [operation start];
}

@end
