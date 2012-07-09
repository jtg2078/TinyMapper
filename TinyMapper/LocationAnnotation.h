//
//  LocationAnnotation.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/30/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Entry.h"

@interface LocationAnnotation : NSObject <MKAnnotation>
{
    
}

@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * address;
@property (strong, nonatomic) NSNumber * lat;
@property (strong, nonatomic) NSNumber * lng;
@property (strong, nonatomic) Entry    * entry;

@end
