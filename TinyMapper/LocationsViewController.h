//
//  LocationsViewController.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/30/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>
#import "GData.h"
#import "AppManager.h"

@interface LocationsViewController : UITableViewController
{
    
}

@property (strong, nonatomic) GDataServiceGoogleSpreadsheet *spreadsheetService;
@property (nonatomic, strong) GDataEntrySpreadsheet *spreadsheet;
@property (nonatomic, strong) GDataFeedBase *mEntryFeed;
@property (nonatomic, strong) CLGeocoder *gencoder;
@property (nonatomic, weak) NSOperationQueue *mainQueue;


@property (nonatomic, weak) AppManager *manager;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSMutableDictionary *dict;

@end
