//
//  LocationViewController.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/25/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "ListsViewController.h"
#import "LocationsViewController.h"

@interface ListsViewController ()

@end

@implementation ListsViewController

#pragma mark - define

#pragma mark - synthesize

@synthesize apiManager;
@synthesize spreadSheetService;
@synthesize spreadSheetFeed;

#pragma mark - init

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // ---------- retrieve the google spreadsheets ----------
    
    if(self.spreadSheetService == nil)
    {
        spreadSheetService = [[GDataServiceGoogleSpreadsheet alloc] init];
        
        [self.spreadSheetService setShouldCacheResponseData:YES];
        [self.spreadSheetService setServiceShouldFollowNextLinks:YES];
        
        // username/password may change
        NSString *username = @"jtg2078@gmail.com";
        NSString *password = @"jthegreat";
        
        [self.spreadSheetService setUserCredentialsWithUsername:username
                                                       password:password];
    }
    
    NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
    [self.spreadSheetService fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        
        self.spreadSheetFeed = (GDataFeedSpreadsheet*)feed;
        [self.tableView reloadData];
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.spreadSheetFeed.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    GDataEntrySpreadsheet *spreadsheet = [self.spreadSheetFeed.entries objectAtIndex:indexPath.row];
    
    cell.textLabel.text = spreadsheet.title.stringValue;
    cell.detailTextLabel.text = spreadsheet.updatedDate.stringValue;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GDataEntrySpreadsheet *spreadsheet = [self.spreadSheetFeed.entries objectAtIndex:indexPath.row];
    if([spreadsheet.title.stringValue isEqualToString:@"吃的"] == YES)
    {
        LocationsViewController *lvc = [[LocationsViewController alloc] init];
        lvc.spreadsheetService = self.spreadSheetService;
        lvc.spreadsheet = spreadsheet;
        
        [self.navigationController pushViewController:lvc animated:YES];
    }
}

@end
