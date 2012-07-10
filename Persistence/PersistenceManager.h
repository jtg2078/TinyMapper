//
//  PersistenceManager.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/9/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"
#import "WebLink.h"

@interface PersistenceManager : NSObject
{
    
}

@property (nonatomic, strong) NSManagedObjectContext *context;

+ (PersistenceManager *)sharedInstance;

- (Place *)getPlaceIfExistWithIdentifier:(NSString *)identifier;
- (Place *)getOrCreatePlaceWithIdentifier:(NSString *)identifier;
- (void)deletePlaceIfExistWithIdentifier:(NSString *)identifier;

@end
