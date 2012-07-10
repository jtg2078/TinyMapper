//
//  AppManager.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/2/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "AppManager.h"
#import "AppDelegate.h"
//#import "GeocodingOperation.h"
#import "AppleGeocodingOperation.h"
#import "GoogleGeocodingOperation.h"

static AppManager *singletonManager = nil;

typedef void (^UpdateSuccessBlock)(NSString *message, NSArray *results);
typedef void (^UpdateFailureBlock)(NSString *message, NSError *error);

@interface AppManager ()

@property (readwrite, nonatomic, copy) UpdateSuccessBlock updateSuccess;
@property (readwrite, nonatomic, copy) UpdateFailureBlock updateFailure;

@end

@implementation AppManager

#pragma mark - define

#define DEFAULT_GOOGLE_ID       @"tinymapper@gmail.com"
#define DEFAULT_GOOGLE_PW       @"tinymapper1234"

#define DEFAULT_TARGET_FILE     @"吃的"

#define KEY_NAME        @"店名"
#define KEY_TYPE        @"類型"
#define KEY_ADDR        @"地址"
#define KEY_TELE        @"聯絡資訊"
#define KEY_RSVP        @"需要定位"
#define KEY_REVIEW      @"去過沒～" 
#define KEY_NOTE        @"備註"

#define DEFAULT_UPDATE_FAILURE_MESSAGE      @"更新失敗"
#define DEFAULT_UPDATE_SUCCESS_MESSAGE      @"更新完成"

#define DEFAULT_API_URL     @"http://localhost:8081"

#define API_SUCCESS_FLAG    @"success"
#define API_FAILIRE_FLAG    @"failure"

#define PLACE_UPDATE_GENERATION_KEY            @"placeUpdateGeneration"

#pragma mark - synthesize

@synthesize service;
@synthesize client;
@synthesize categories;
@synthesize updateSuccess;
@synthesize updateFailure;
@synthesize context;
@synthesize mainQueue;
@synthesize geocoder;

#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    service = [[GDataServiceGoogleSpreadsheet alloc] init];
    
    [self.service setShouldCacheResponseData:YES];
    [self.service setServiceShouldFollowNextLinks:YES];
    
    [self.service setUserCredentialsWithUsername:DEFAULT_GOOGLE_ID
                                        password:DEFAULT_GOOGLE_PW];
    
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:DEFAULT_API_URL]];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    self.mainQueue = [NSOperationQueue mainQueue];
    self.mainQueue.maxConcurrentOperationCount = 1;
    
    geocoder = [[CLGeocoder alloc] init];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
               selector:@selector(handleGeocodeNotification:) 
                   name:GeocodeFinishedNotification 
                 object:nil];
}

#pragma mark - main methods

- (void)updateSuccess:(void (^)(NSString *message, NSArray *results))success 
              failure:(void (^)(NSString *message, NSError *error))failure
{
    self.updateSuccess = success;
    self.updateFailure = failure;
    
    NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
    [self.service fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        
        if(error != nil)
        {
            NSLog(@"error occured while retrieving document list: %@", [error description]);
            if(self.updateFailure)
                self.updateFailure(DEFAULT_UPDATE_FAILURE_MESSAGE, error);
            return;
        }
        
        for(GDataEntrySpreadsheet *sheet in feed.entries)
        {
            if([sheet.title.stringValue isEqualToString:DEFAULT_TARGET_FILE] == YES)
            {
                [self processSheet:sheet];
                return;
            }
        }
        
        NSLog(@"error occured while retrieving document list: %@", [error description]);
        if(self.updateFailure)
            self.updateFailure([NSString stringWithFormat:@"找不到文件: %@", DEFAULT_TARGET_FILE], nil);
        
    }];
}

- (void)uploadLocationEntry:(Entry *)entry 
              resultHandler:(void (^)(NSString *message, NSError *error))resultHandler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if(entry.name)
        [params setObject:entry.name            forKey:@"name"];
    if(entry.type)
        [params setObject:entry.type            forKey:@"type"];
    if(entry.address)
        [params setObject:entry.address         forKey:@"address"];
    if(entry.lat)
        [params setObject:entry.lat.stringValue forKey:@"lat"];
    if(entry.lon)
        [params setObject:entry.lon.stringValue forKey:@"lon"];
    if(entry.tel)
        [params setObject:entry.tel             forKey:@"tel"];
    if(entry.hours)
        [params setObject:entry.hours           forKey:@"hours"];
    if(entry.reservation)
        [params setObject:entry.reservation     forKey:@"reservation"];
    if(entry.review)
        [params setObject:entry.review          forKey:@"review"];
    if(entry.note)
        [params setObject:entry.note            forKey:@"note"];
    
    NSMutableURLRequest *request = [self.client requestWithMethod:@"POST" 
                                                             path:@"update" 
                                                       parameters:params];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *result = [JSON objectForKey:@"result"];
        NSString *message = nil;
        if([result isEqualToString:API_SUCCESS_FLAG] == YES)
        {
            message = [NSString stringWithFormat:@"The entry has been uploaded succesfully and assigned to Id: %@", [JSON objectForKey:@"id"]];
        }
        else
        {
            message = [NSString stringWithFormat:@"The entry failed to upload with reason: %@", [JSON objectForKey:@"reason"]];
        }
        
        if(resultHandler)
            resultHandler(message, nil);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        if(resultHandler)
            resultHandler(@"Error occured from AFNetworking", error);
    }];
    
    [operation start];
}

- (void)bulkUploadLocationEntries:(NSArray *)entries
{
    for (Entry *e in entries)
    {
        [self uploadLocationEntry:e resultHandler:^(NSString *message, NSError *error) {
            
            if(error == nil)
                NSLog(@"%@", message);
            else
                NSLog(@"%@: %@", message, [error description]);
        }];
    }
}

#pragma mark - data processing

- (void)processSheet:(GDataEntrySpreadsheet *)sheet
{
    [self.service fetchFeedWithURL:sheet.worksheetsFeedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        
        if(error != nil)
        {
            NSLog(@"error occured while retrieving target spreadsheet: %@", [error description]);
            if(self.updateFailure)
                self.updateFailure(DEFAULT_UPDATE_FAILURE_MESSAGE, error);
            return;
        }
        
        GDataFeedWorksheet *worksheetFeed = (GDataFeedWorksheet *)feed;
        
        // just grab the first worksheet if availabile
        if(worksheetFeed.entries.count)
        {
            [self processWorksheet:[worksheetFeed.entries objectAtIndex:0]];
        }
        else
        {
            if(self.updateFailure)
                self.updateFailure(@"文件是空的", nil);
            return;
        }
    }];
}

- (void)processWorksheet:(GDataEntryWorksheet *)worksheet
{
    [self.service fetchFeedWithURL:worksheet.listFeedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        
        if(error != nil)
        {
            NSLog(@"error occured while retrieving target spreadsheet: %@", [error description]);
            if(self.updateFailure)
                self.updateFailure(DEFAULT_UPDATE_FAILURE_MESSAGE, error);
            return;
        }
        
        [self processEntry:feed];
    }];
}

- (void)processEntry:(GDataFeedBase *)entry
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *entries = [NSMutableArray array];
    
    // update generation
    int updateGeneration = [self getPlaceUpdateGeneration];
    updateGeneration += 1;
    [self setPlaceUpdateGeneration:updateGeneration];
    
    for(GDataEntrySpreadsheetList *listEntry in entry)
    {
        NSString *name = [[listEntry customElementForName:KEY_NAME] stringValue];
        NSString *type = [[listEntry customElementForName:KEY_TYPE] stringValue];
        NSString *addr = [[listEntry customElementForName:KEY_ADDR] stringValue];
        NSString *tele = [[listEntry customElementForName:KEY_TELE] stringValue];
        NSString *rsvp = [[listEntry customElementForName:KEY_RSVP] stringValue];
        NSString *review = [[listEntry customElementForName:KEY_REVIEW] stringValue];
        NSString *note = [[listEntry customElementForName:KEY_NOTE] stringValue];
        
        NSMutableArray *array = nil;
        
        array = [dict objectForKey:type];
        if(array == nil)
        {
            array = [NSMutableArray array];
        }
        
        Entry *e = [[Entry alloc] init];
        e.identifier = listEntry.identifier;
        e.name = name;
        e.type = type;
        e.address = addr;
        e.tel = tele;
        e.reservation = rsvp;
        e.review = review;
        e.note = note;
        
        [array addObject:e];
        [dict setObject:array forKey:type];
        [entries addObject:e];
        
        // core data
        [self addOrUpdatePlaceWithIdentifier:listEntry.identifier 
                                        name:name 
                                        type:type 
                                     address:addr 
                                         tel:tele 
                                         lat:nil 
                                         lon:nil 
                                       hours:nil 
                                     reserve:rsvp 
                                      review:review 
                                        note:note 
                                        misc:nil 
                                   updateGen:updateGeneration];
    }
    
    // save them
    NSError *error = nil;
    [self.context save:&error];
    
    // run the background geocoded task
    [self runAppleGeocoding];
    
    self.categories = dict;
    
    if(self.updateSuccess)
        self.updateSuccess(DEFAULT_UPDATE_SUCCESS_MESSAGE, [self.categories allValues]);
    
    //[self bulkUploadLocationEntries:entries];
}

#pragma mark - background tasks

- (void)runAppleGeocoding
{
    NSArray *places = [self getUnGeocodedPlaces];
    
    for(Place *p in places)
    {
        AppleGeocodingOperation *operation = [[AppleGeocodingOperation alloc] initWithAddress:p.address identifier:p.identifier];
        [self.mainQueue addOperation:operation];
    }
}

- (void)runGoogleGeocoding
{
    
}

- (void)handleGeocodeNotification:(NSNotification *)notif
{
    BOOL isSuccessful = [[notif.userInfo objectForKey:GeocodeResultKeyResult] boolValue];
    NSString *message = [notif.userInfo objectForKey:GeocodeResultKeyMessage];
    NSStream *address = [notif.userInfo objectForKey:GeocodeResultKeyAddress];
    
    if(isSuccessful)
    {
        NSString *identifier = [notif.userInfo objectForKey:GeocodeResultKeyIdentifier];
        Place *p = [self getPlaceIfExistWithIdentifier:identifier];
        
        if(p)
        {
            p.lat = [notif.userInfo objectForKey:GeocodeResultKeyLat];
            p.lon = [notif.userInfo objectForKey:GeocodeResultKeyLon];
            p.addressFormatted = [notif.userInfo objectForKey:GeocodeResultKeyFormattedAddress];
            p.geocoded = [NSNumber numberWithBool:YES];
            
            NSError *error = nil;
            [self.context save:&error];
        }
    }
    
    NSLog(@"Geocoding - %@ Result: %@", message, address);
}

#pragma mark - update generation

- (int)getPlaceUpdateGeneration
{
    int savedValue = [[NSUserDefaults standardUserDefaults] integerForKey:PLACE_UPDATE_GENERATION_KEY];
    return savedValue;
}

- (void)setPlaceUpdateGeneration:(int)anInt
{
    [[NSUserDefaults standardUserDefaults] setInteger:anInt forKey:PLACE_UPDATE_GENERATION_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - persistence methods

- (void)addOrUpdatePlaceWithIdentifier:(NSString *)identifier 
                                  name:(NSString *)name 
                                  type:(NSString *)type 
                               address:(NSString *)address 
                                   tel:(NSString *)tel 
                                   lat:(NSNumber *)lat 
                                   lon:(NSNumber *)lon 
                                 hours:(NSString *)hours 
                               reserve:(NSString *)reserve 
                                review:(NSString *)review 
                                  note:(NSString *)note 
                                  misc:(NSString *)misc 
                             updateGen:(int)generation
{
    Place *place = [self getPlaceIfExistWithIdentifier:identifier];
    
    if(place)
    {
        // update
        BOOL isDirty = NO;
        if(name.length && [name isEqualToString:place.placeName] == NO)
        {
            place.placeName = name;
            isDirty = YES;
        }
        
        if(type.length && [type isEqualToString:place.placeType] == NO)
        {
            place.placeName = type;
            isDirty = YES;
        }
        
        if(address.length && [address isEqualToString:place.address] == NO)
        {
            place.address = address;
            isDirty = YES;
            
            if(lat == nil || lon == nil)
                place.geocoded = [NSNumber numberWithBool:NO];
        }
        
        if(tel.length && [tel isEqualToString:place.tel] == NO)
        {
            place.tel = tel;
            isDirty = YES;
        }
        
        if(lat && [lat isEqualToNumber:place.lat] == NO)
        {
            place.lat = lat;
            isDirty = YES;
        }
        
        if(lon && [lon isEqualToNumber:place.lon] == NO)
        {
            place.lon = lon;
            isDirty = YES;
        }
        
        if(hours.length && [hours isEqualToString:place.hoursInfo] == NO)
        {
            place.hoursInfo = hours;
            isDirty = YES;
        }
        
        if(reserve.length && [reserve isEqualToString:place.reservationInfo] == NO)
        {
            place.reservationInfo = reserve;
            isDirty = YES;
        }
        
        if(review.length && [review isEqualToString:place.reviewInfo] == NO)
        {
            place.reviewInfo = review;
            isDirty = YES;
        }
        
        if(note.length && [note isEqualToString:place.noteInfo] == NO)
        {
            place.noteInfo = note;
            isDirty = YES;
        }
        
        if(misc.length && [misc isEqualToString:place.miscInfo] == NO)
        {
            place.miscInfo = misc;
            isDirty = YES;
        }
        
        if(isDirty)
        {
            place.dateModified = [NSDate date];
        }
    }
    else
    {
        place = [self getOrCreatePlaceWithIdentifier:identifier];
        place.identifier = identifier;
        place.placeName = name;
        place.placeType = type;
        place.address = address;
        place.tel = tel;
        place.lat = lat;
        place.lon = lon;
        place.hoursInfo = hours;
        place.reservationInfo = reserve;
        place.reviewInfo = review;
        place.noteInfo = note;
        place.dateAdded = [NSDate date];
        place.dateModified = [NSDate date];
        place.miscInfo = misc;
        place.uploaded = [NSNumber numberWithBool:NO];
        if(lat && lon)
            place.geocoded = [NSNumber numberWithBool:YES];
        else
            place.geocoded = [NSNumber numberWithBool:NO];
    }
    place.updateGeneration = [NSNumber numberWithInt:generation];
}

- (Place *)getPlaceIfExistWithIdentifier:(NSString *)identifier
{
    Place *place = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    
    NSError *error = nil;
    place = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !place)
        return nil;
    
    return place;
}

- (Place *)getOrCreatePlaceWithIdentifier:(NSString *)identifier
{
    Place *place = [self getPlaceIfExistWithIdentifier:identifier];
    
    if (!place) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        place.identifier = identifier;
    }
    return place;
}

- (void)deletePlaceIfExistWithIdentifier:(NSString *)identifier
{
    Place *place = [self getPlaceIfExistWithIdentifier:identifier];
    
    if(place)
        [context deleteObject:place];
}

- (NSArray *)getUnGeocodedPlaces
{
    // find the items that need to be geocoded
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"geocoded = %@", [NSNumber numberWithBool:NO]];
    request.includesPendingChanges = YES;
    
    NSArray *places = nil;
    NSError *error = nil;
    places = [self.context executeFetchRequest:request error:&error];
    
    if(error)
    {
        NSLog(@"error while runGeocodingTask: %@", [error description]);
        return nil;
    }
    
    return places;
}

#pragma mark - singleton implementation code

+ (AppManager *)sharedInstance {
    
    static dispatch_once_t pred;
    static AppManager *manager;
    
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singletonManager == nil) {
            singletonManager = [super allocWithZone:zone];
            return singletonManager;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
