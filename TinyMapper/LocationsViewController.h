//
//  LocationsViewController.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/30/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GData.h"

@interface LocationsViewController : UITableViewController
{
    
}

@property (strong, nonatomic) GDataServiceGoogleSpreadsheet *spreadsheetService;
@property (nonatomic, strong) GDataEntrySpreadsheet *spreadsheet;
@property (nonatomic, strong) GDataFeedBase *mEntryFeed;
@property (nonatomic, strong) CLGeocoder *gencoder;

@end
