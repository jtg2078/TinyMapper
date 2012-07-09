//
//  GeocodingOperation.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/8/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "GeocodingOperation.h"
#import "AFJSONRequestOperation.h"


NSString *GeocodeFinishedNotification = @"GeocodeFinishedNotification";
NSString *GeocodeResultKeyIdentifier = @"GeocodeResultKeyIdentifier";
NSString *GeocodeResultKeyLat = @"GeocodeResultKeyLat";
NSString *GeocodeResultKeyLon = @"GeocodeResultKeyLon";
NSString *GeocodeResultKeyFormattedAddress = @"GeocodeResultKeyFormattedAddress";
NSString *GeocodeResultKeyMessage = @"GeocodeResultKeyMessage";

@implementation GeocodingOperation

@synthesize address;
@synthesize identifier;
@synthesize geocoder;
@synthesize message;

- (id)initWithAddress:(NSString *)anAddress identifier:(NSString *)anIdentifier
{
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
        self.address = anAddress;
        self.identifier = anIdentifier;
        self.message = @"";
        geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (BOOL)isConcurrent 
{
    return YES;
}

- (BOOL)isExecuting 
{
    return executing;
}

- (BOOL)isFinished 
{
    return finished;
}

- (void)start 
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [self geocode];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)geocode 
{
    [self.geocoder geocodeAddressString:self.address completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(placemarks == nil || placemarks.count == 0)
        {
            NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                
                NSString *status = [JSON objectForKey:@"status"];
                if([status isEqualToString:@"OK"] == YES)
                {
                    NSDictionary *result = [[JSON objectForKey:@"results"] lastObject];
                    NSDictionary *geometry = [result objectForKey:@"geometry"];
                    NSDictionary *location = [geometry objectForKey:@"location"];
                    NSNumber *lat = [location objectForKey:@"lat"];
                    NSNumber *lng = [location objectForKey:@"lng"];
                    NSString *formattedAddress = [result objectForKey:@"formatted_address"];
                    
                    if(formattedAddress.length == 0)
                        NSLog(@"wtf?");
                    
                    [self completeOperationResult:YES 
                                              lat:lat 
                                              lon:lng 
                                 formattedAddress:formattedAddress];
                }
                else
                {
                    [self completeOperationResult:NO 
                                              lat:nil 
                                              lon:nil 
                                 formattedAddress:nil];
                    self.message = @"Google Map API 無法解析地址 :(";
                }
                
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                
                [self completeOperationResult:NO 
                                          lat:nil 
                                          lon:nil 
                             formattedAddress:nil];
                self.message = @"無法連線到Google Map API";
            }];
            
            [operation start];
        }
        else
        {
            CLPlacemark *placemark = [placemarks lastObject];
            NSNumber *lat = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
            NSNumber *lng = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];
            NSString *formattedAddress = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            
            [self completeOperationResult:YES 
                                      lat:lat 
                                      lon:lng 
                         formattedAddress:formattedAddress];
        }
    }];
}

- (void)completeOperationResult:(BOOL)isSuccess 
                            lat:(NSNumber *)lat 
                            lon:(NSNumber *)lon 
               formattedAddress:(NSString *)formattedAddress 
{
    if(formattedAddress.length == 0)
        NSLog(@"wtf?");
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if(isSuccess)
    {
        [info setObject:identifier forKey:GeocodeResultKeyIdentifier];
        [info setObject:lat forKey:GeocodeResultKeyLat];
        [info setObject:lon forKey:GeocodeResultKeyLon];
        [info setObject:formattedAddress forKey:GeocodeResultKeyFormattedAddress];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [center postNotificationName:GeocodeFinishedNotification 
                                  object:nil 
                                userInfo:info];
        });
    }
    else
    {
        [info setObject:self.message forKey:GeocodeResultKeyMessage];
    }
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


@end
