//
//  Entry.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/2/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Entry : NSObject <NSCoding, MKAnnotation>
{
    
}

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * type;

@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSString * formattedAddress;
@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * lon;

@property (nonatomic, strong) NSString * tel;
@property (nonatomic, strong) NSString * hours;


@property (nonatomic, strong) NSString * reservation;
@property (nonatomic, strong) NSString * review;
@property (nonatomic, strong) NSString * note;

@end
