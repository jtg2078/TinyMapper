//
//  AppleGeocodingOperation.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/10/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "AppleGeocodingOperation.h"

@implementation AppleGeocodingOperation

- (void)geocode
{
    [super geocode];
    
    [self.geocoder geocodeAddressString:self.address completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(error)
        {
            self.message = [NSString stringWithFormat:@"error while performing self.geocoder geocodeAddressString: %@", [error description]];
            [self completeOperationResult:NO lat:nil lon:nil formattedAddress:nil];
        }
        else if(placemarks.count == 0)
        {
            self.message = @"self.geocoder geocodeAddressString did not return any result";
            [self completeOperationResult:NO lat:nil lon:nil formattedAddress:nil];
        }
        else
        {
            CLPlacemark *placemark = [placemarks lastObject];
            NSNumber *lat = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
            NSNumber *lng = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];
            NSString *formattedAddress = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            
            self.message = [NSString stringWithFormat:@"self.geocoder geocodeAddressString success with # of results: %d", placemarks.count];
            [self completeOperationResult:YES 
                                      lat:lat 
                                      lon:lng 
                         formattedAddress:formattedAddress];
        }
    }];
}

@end
