//
//  WebLink.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/9/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface WebLink : NSManagedObject

@property (nonatomic, retain) NSString * linkTitle;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) NSNumber * isProcessed;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSString * linkSummary;
@property (nonatomic, retain) NSData * linkPhoto;
@property (nonatomic, retain) NSString * cacheLocation;
@property (nonatomic, retain) Place *ofPlace;

@end
