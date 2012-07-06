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

@synthesize manager;
@synthesize array;

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
    
    // -------------------- naivgation bar --------------------
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"重新整理", nil) 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(loadData)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
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
    //return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Entry *e = [[self.array objectAtIndex:section] lastObject];
    return e.type;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [[self.array objectAtIndex:section] count];
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
    
    Entry *e = [[self.array objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = e.name;
    cell.detailTextLabel.text = e.address;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [SVProgressHUD show];
    
    Entry *e = [[self.array objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if(e.lat && e.lon)
    {
        [self showMapViewControllerWithLocationName:e.name 
                                            address:e.address 
                                                lat:e.lat
                                                lng:e.lon 
                                              entry:e];
        [SVProgressHUD dismiss];
        return;
    }
    
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
                    
                    [self showMapViewControllerWithLocationName:e.name 
                                                        address:e.address 
                                                            lat:lat 
                                                            lng:lng 
                                                          entry:e];
                    
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

            [self showMapViewControllerWithLocationName:e.name 
                                                address:e.address 
                                                    lat:lat 
                                                    lng:lng 
                                                  entry:e];
            
            [SVProgressHUD dismiss];
        }
    }];
}

#pragma mark - load data

- (void)loadData
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"下載中...", nil)];
    [manager updateSuccess:^(NSString *message, NSArray *results) {
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

@end
