//
//  AppManager.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/2/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "AppManager.h"

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

#pragma mark - synthesize

@synthesize service;
@synthesize client;
@synthesize categories;
@synthesize updateSuccess;
@synthesize updateFailure;

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
        e.name = name;
        e.type = type;
        e.address = addr;
        e.tel = tele;
        e.reservation = rsvp;
        e.review = review;
        e.note = note;
        
        [array addObject:e];
        [dict setObject:array forKey:type];
    }
    
    self.categories = dict;
    
    if(self.updateSuccess)
        self.updateSuccess(DEFAULT_UPDATE_SUCCESS_MESSAGE, [self.categories allValues]);
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
