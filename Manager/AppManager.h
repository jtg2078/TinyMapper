//
//  AppManager.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/2/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>

#import "GData.h"
#import "AFNetworking.h"
#import "Entry.h"
#import "Place.h"
#import "WebLink.h"


@interface AppManager : NSObject
{
    
}

+ (AppManager *)sharedInstance;

@property (strong, nonatomic) AFHTTPClient                  * client;
@property (strong, nonatomic) GDataServiceGoogleSpreadsheet * service;
@property (strong, nonatomic) NSDictionary                  * categories;
@property (nonatomic, strong) NSManagedObjectContext        * context;
@property (nonatomic, strong) NSOperationQueue              * mainQueue;
@property (nonatomic, strong) CLGeocoder                    * geocoder;

- (void)updateSuccess:(void (^)(NSString *message, NSArray *results))success 
              failure:(void (^)(NSString *message, NSError *error))failure;

- (void)uploadLocationEntry:(Entry *)entry 
              resultHandler:(void (^)(NSString *message, NSError *error))resultHandler;

- (Place *)getPlaceIfExistWithIdentifier:(NSString *)identifier;
- (Place *)getOrCreatePlaceWithIdentifier:(NSString *)identifier;
- (void)deletePlaceIfExistWithIdentifier:(NSString *)identifier;

@end
