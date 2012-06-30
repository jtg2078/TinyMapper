//
//  LocationsViewController.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/30/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "LocationsViewController.h"
#import "MapViewController.h"
#import "RootViewController.h"

#import "SVProgressHUD.h"
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"


@implementation LocationsViewController

#pragma mark - synthesize

@synthesize spreadsheetService;
@synthesize spreadsheet;
@synthesize mEntryFeed;
@synthesize gencoder;

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
    
    gencoder = [[CLGeocoder alloc] init];
    
    if(self.spreadsheet)
    {
        NSURL *feedURL = [self.spreadsheet worksheetsFeedURL];
        if (feedURL) 
        {
            [SVProgressHUD show];
            [self.spreadsheetService fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
                
                GDataFeedWorksheet *worksheetFeed = (GDataFeedWorksheet *)feed;
                // just grab the first worksheet if availabile
                if(worksheetFeed.entries.count)
                {
                    GDataEntryWorksheet *worksheet = [worksheetFeed.entries objectAtIndex:0];
                    if(worksheet)
                    {
                        NSURL *worksheetURL = worksheet.listFeedURL;
                        if(worksheetURL)
                        {
                            [self.spreadsheetService fetchFeedWithURL:worksheetURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
                                
                                self.mEntryFeed = feed;
                                
                                [self.tableView reloadData];
                            }];
                            [SVProgressHUD dismiss];
                        }
                    }
                }
                
            }];
        }
    }
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
    int rows = self.mEntryFeed.entries.count;
    return rows;
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
    GDataEntrySpreadsheetList *listEntry = [self.mEntryFeed.entries objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [[listEntry customElementForName:@"店名"] stringValue];
    cell.detailTextLabel.text = [[listEntry customElementForName:@"地址"] stringValue];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [SVProgressHUD show];
    
    GDataEntrySpreadsheetList *listEntry = [self.mEntryFeed.entries objectAtIndex:indexPath.row];
    NSString *address = [[listEntry customElementForName:@"地址"] stringValue];
    //address = @"1 Infinite Loop, Cupertino, CA";
    //address = @"110台北市信義區信義路五段7號";
    [self.gencoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        
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
                    
                    [self showMapViewControllerWithLocationName:[[listEntry customElementForName:@"店名"] stringValue] 
                                                        address:[[listEntry customElementForName:@"地址"] stringValue] 
                                                            lat:lat 
                                                            lng:lng];
                    
                    [SVProgressHUD dismiss];
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:@"Google Map API 無法解析地址 :("];
                }
                
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                
                [SVProgressHUD showErrorWithStatus:@"Google Map API 無法解析地址 :("];
            }];
            
            [operation start];
        }
        else
        {
            CLPlacemark *placemark = [placemarks lastObject];
            NSNumber *lat = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
            NSNumber *lng = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];
            
            [self showMapViewControllerWithLocationName:[[listEntry customElementForName:@"店名"] stringValue] 
                                                address:[[listEntry customElementForName:@"地址"] stringValue] 
                                                    lat:lat 
                                                    lng:lng];
            
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)showMapViewControllerWithLocationName:(NSString *)name 
                                      address:(NSString *)address 
                                          lat:(NSNumber *)lat 
                                          lng:(NSNumber *)lng
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MapViewController *mvc = delegate.mapViewController;
    
    mvc.locationName = name;
    mvc.locationAddress = address;
    mvc.lat = lat;
    mvc.lng = lng;
    
    [mvc updateAndDisplay];
    
    [delegate.rootViewController revealToggle:nil];
    //[self.navigationController.parentViewController performSelector:@selector(revealToggle:)];
}

@end
