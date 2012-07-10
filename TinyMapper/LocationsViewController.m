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

#import "Place.h"


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
@synthesize placeFRC;

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
    
    appDelegate = [[UIApplication sharedApplication] delegate];
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
    /*
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
               selector:@selector(handleGeocodeNotification:) 
                   name:GeocodeFinishedNotification 
                 object:nil];
    */
    // -------------------- table view data --------------------
    
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    // setup fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
    
    // setup sorting
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"placeType" ascending:YES];
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"address" ascending:YES];
    NSArray *sortArray = [NSArray arrayWithObjects:sort1, sort2, nil];
    fetchRequest.sortDescriptors = sortArray;
    
    placeFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                   managedObjectContext:context 
                                                     sectionNameKeyPath:@"placeType" 
                                                              cacheName:nil];
    
    NSError *error = nil;
    if([placeFRC performFetch:&error] == NO)
    {
        NSLog(@"error while placeFRC performFetch: %@", [error description]);
    }
    else
    {
        [self.tableView reloadData];
        placeFRC.delegate = self;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setGencoder:nil];
    [self setArray:nil];
    self.placeFRC.delegate = nil;
    [self setPlaceFRC:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex 
     forChangeType:(NSFetchedResultsChangeType)type 
{
    switch(type) 
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath 
{
    
    UITableView *tableView = self.tableView;
    
    switch(type) 
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    [self.tableView endUpdates];
}

#pragma mark - cell configuration

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Place *place = [self.placeFRC objectAtIndexPath:indexPath];
    
    cell.textLabel.text = place.placeName;
    cell.detailTextLabel.text = place.address;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.placeFRC.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.placeFRC.sections objectAtIndex:section];
    return sectionInfo.name;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.placeFRC.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
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
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Place *place = [self.placeFRC objectAtIndexPath:indexPath];
    
    Entry *e = [[Entry alloc] init];
    e.identifier = place.identifier;
    e.name = place.placeName;
    e.type = place.placeType;
    e.address = place.address;
    e.formattedAddress = place.addressFormatted;
    e.lat = place.lat;
    e.lon = place.lon;
    e.tel = place.tel;
    e.hours = place.hoursInfo;
    e.reservation = place.reservationInfo;
    e.review = place.reviewInfo;
    e.note = place.noteInfo;
    
    [self geocodeEntry:e andShowInMap:YES];
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
