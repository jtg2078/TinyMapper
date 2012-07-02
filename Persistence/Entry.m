//
//  Entry.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/2/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "Entry.h"

@implementation Entry

#pragma mark - synthesize

@synthesize name;
@synthesize type;
@synthesize address;
@synthesize lat;
@synthesize lon;
@synthesize tel;
@synthesize hours;
@synthesize reservation;
@synthesize review;
@synthesize note;

- (void)encodeWithCoder:(NSCoder *)coder 
{
    [coder encodeObject:self.name           forKey:@"EntryName"];
    [coder encodeObject:self.type           forKey:@"EntryType"];
    [coder encodeObject:self.address        forKey:@"EntryAddress"];
    [coder encodeObject:self.lat            forKey:@"EntryLat"];
    [coder encodeObject:self.lon            forKey:@"EntryLon"];
    [coder encodeObject:self.tel            forKey:@"EntryTel"];
    [coder encodeObject:self.hours          forKey:@"EntryHours"];
    [coder encodeObject:self.reservation    forKey:@"EntryReservation"];
    [coder encodeObject:self.review         forKey:@"EntryReview"];
    [coder encodeObject:self.note           forKey:@"EntryNote"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self != nil) {
        self.name =         [coder decodeObjectForKey:@"EntryName"];       
        self.type =         [coder decodeObjectForKey:@"EntryType"];       
        self.address =      [coder decodeObjectForKey:@"EntryAddress"];   
        self.lat =          [coder decodeObjectForKey:@"EntryLat"];        
        self.lon =          [coder decodeObjectForKey:@"EntryLon"];        
        self.tel =          [coder decodeObjectForKey:@"EntryTel"];        
        self.hours =        [coder decodeObjectForKey:@"EntryHours"];      
        self.reservation =  [coder decodeObjectForKey:@"EntryReservation"];
        self.review =       [coder decodeObjectForKey:@"EntryReview"];     
        self.note =         [coder decodeObjectForKey:@"EntryNote"];       
	}
	return self;
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = self.lat.doubleValue;
    theCoordinate.longitude = self.lon.doubleValue;
    return theCoordinate; 
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.address;
}

@end
