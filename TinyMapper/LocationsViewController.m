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

#import "GeocodingOperation.h"


@implementation LocationsViewController

#pragma mark - synthesize

@synthesize spreadsheetService;
@synthesize spreadsheet;
@synthesize mEntryFeed;
@synthesize gencoder;

@synthesize manager;
@synthesize array;
@synthesize mainQueue;
@synthesize dict;

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
    
    // -------------------- view controller --------------------
    
    gencoder = [[CLGeocoder alloc] init];
    manager = [AppManager sharedInstance];
    self.mainQueue = [NSOperationQueue mainQueue];
    
    // -------------------- naivgation bar --------------------
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"重新整理", nil) 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(loadData)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    // -------------------- notification --------------------
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
               selector:@selector(handleGeocodeNotification:) 
                   name:GeocodeFinishedNotification 
                 object:nil];
    
    // -------------------- table view data --------------------
    
    [self loadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setGencoder:nil];
    [self setArray:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.array.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *sectionArray = [self.array objectAtIndex:section];
    Entry *e = [sectionArray lastObject];
    return [NSString stringWithFormat:@"%@(%d)", e.type, sectionArray.count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [self.array objectAtIndex:section];
    int rows = [sectionArray count];
    if(rows > 1)
        rows++;
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
    
    NSArray *sectionArray = [self.array objectAtIndex:indexPath.section];
    
    if(sectionArray.count == 1)
    {
        Entry *e = [[self.array objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.textLabel.text = e.name;
        cell.detailTextLabel.text = e.address;
    }
    else
    {
        if(indexPath.row == sectionArray.count)
        {
            cell.textLabel.text = @"標示全部...";
            cell.detailTextLabel.text = @"";
        }
        else
        {
            Entry *e = [[self.array objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            cell.textLabel.text = e.name;
            cell.detailTextLabel.text = e.address;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *sectionArray = [self.array objectAtIndex:indexPath.section];
    
    if(indexPath.row == sectionArray.count)
    {
        [self batchGeocodeEntries:sectionArray];
    }
    else
    {
        Entry *e = [sectionArray objectAtIndex:indexPath.row];
        [self geocodeEntry:e andShowInMap:YES];
    }
}

#pragma mark - load data

- (void)loadData
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"下載中...", nil)];
    [manager updateSuccess:^(NSString *message, NSArray *results) {
        self.dict = [NSMutableDictionary dictionary];
        for(NSArray *sections in results)
        {
            for(Entry *e in sections)
            {
                [self.dict setObject:e forKey:e.identifier];
            }
        }
        self.array = results;
        [self.tableView reloadData];
        [SVProgressHUD showSuccessWithStatus:message];
    } failure:^(NSString *message, NSError *error) {
        [SVProgressHUD showErrorWithStatus:message];
    }];
}

#pragma mark - user interaction

- (void)showMapViewControllerWithLocationName:(NSString *)name 
                                      address:(NSString *)address 
                                          lat:(NSNumber *)lat 
                                          lng:(NSNumber *)lng 
                                        entry:(Entry *)e

{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MapViewController *mvc = delegate.mapViewController;
    
    mvc.locationName = name;
    mvc.locationAddress = address;
    mvc.lat = lat;
    mvc.lng = lng;
    mvc.entry = e;
    
    [mvc updateAndDisplay];
    
    [delegate.rootViewController revealToggle:nil];
}

- (void)showMapViewControllerWithMultipleLocations:(NSArray *)locations
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MapViewController *mvc = delegate.mapViewController;
    
    mvc.entries = locations;
    
    [mvc updateAndDisplayMultipleEntries];
    
    [delegate.rootViewController revealToggle:nil];
}

#pragma mark - support methods

- (void)geocodeEntry:(Entry *)e andShowInMap:(BOOL)showInMapView
{
    if(e.lat && e.lon)
    {
        if(showInMapView)
        {
            [self showMapViewControllerWithLocationName:e.name 
                                                address:e.address 
                                                    lat:e.lat
                                                    lng:e.lon 
                                                  entry:e];
        }
        
        return;
    }
    
    [SVProgressHUD show];
    NSString *address = e.address;
    
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
                    
                    e.lat = lat;
                    e.lon = lng;
                    e.formattedAddress = [JSON objectForKey:@"formatted_address"];
                    
                    if(showInMapView)
                    {
                        [self showMapViewControllerWithLocationName:e.name 
                                                            address:e.address 
                                                                lat:e.lat
                                                                lng:e.lon 
                                                              entry:e];
                    }
                    
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
            
            e.lat = lat;
            e.lon = lng;
            e.formattedAddress = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            
            if(showInMapView)
            {
                [self showMapViewControllerWithLocationName:e.name 
                                                    address:e.address 
                                                        lat:e.lat
                                                        lng:e.lon 
                                                      entry:e];
            }
            
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)batchGeocodeEntries:(NSArray *)entries
{
    //NSOperationQueue
    NSMutableArray *operations = [NSMutableArray array];
    for(Entry *e in entries)
    {
        if(e.lat == nil || e.lon == nil)
        {
            GeocodingOperation *operation = [[GeocodingOperation alloc] initWithAddress:e.address 
                                                                             identifier:e.identifier];
            [operations addObject:operation];
        }
    }
    
    [SVProgressHUD showWithStatus:@"讀取中..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NO), ^{
        
        [self.mainQueue addOperations:operations waitUntilFinished:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self showMapViewControllerWithMultipleLocations:entries];
            
            [SVProgressHUD dismiss];
        });
    });
    
    
}

- (void)handleGeocodeNotification:(NSNotification *)notif
{
    Entry *e = [self.dict objectForKey:[notif.userInfo objectForKey:GeocodeResultKeyIdentifier]];
    if(e)
    {
        e.lat = [notif.userInfo objectForKey:GeocodeResultKeyLat];
        e.lon = [notif.userInfo objectForKey:GeocodeResultKeyLon];
        e.formattedAddress = [notif.userInfo objectForKey:GeocodeResultKeyFormattedAddress];
    }
}

@end
