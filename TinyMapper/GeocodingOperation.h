//
//  GeocodingOperation.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/8/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>

extern NSString *GeocodeFinishedNotification;
extern NSString *GeocodeResultKeyResult;
extern NSString *GeocodeResultKeyIdentifier;
extern NSString *GeocodeResultKeyLat;
extern NSString *GeocodeResultKeyLon;
extern NSString *GeocodeResultKeyAddress;
extern NSString *GeocodeResultKeyFormattedAddress;
extern NSString *GeocodeResultKeyMessage;

@interface GeocodingOperation : NSOperation
{
    BOOL        executing;
    BOOL        finished;
}

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) NSString *message;

- (id)initWithAddress:(NSString *)anAddress identifier:(NSString *)anIdentifier;
- (void)geocode;
- (void)completeOperationResult:(BOOL)isSuccess 
                            lat:(NSNumber *)lat 
                            lon:(NSNumber *)lon 
               formattedAddress:(NSString *)formattedAddress;

@end
