//
//  PersistenceManager.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/9/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "PersistenceManager.h"

static PersistenceManager *singletonManager = nil;

@implementation PersistenceManager

#pragma mark - main methods

@synthesize context;

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
    }
    return place;
}

- (void)deletePlaceIfExistWithIdentifier:(NSString *)identifier
{
    Place *place = [self getPlaceIfExistWithIdentifier:identifier];
    
    if(place)
        [context deleteObject:place];
}

#pragma mark - singleton implementation code

+ (PersistenceManager *)sharedInstance {
    
    static dispatch_once_t pred;
    static PersistenceManager *manager;
    
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
