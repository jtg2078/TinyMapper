//
//  LocationViewController.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/25/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIManager.h"
#import "GData.h"

@interface ListsViewController : UITableViewController
{
    
}

@property (strong, nonatomic) APIManager *apiManager;
@property (strong, nonatomic) GDataServiceGoogleSpreadsheet *spreadSheetService;
@property (strong, nonatomic) GDataFeedSpreadsheet *spreadSheetFeed;

@end
