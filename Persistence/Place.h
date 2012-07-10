//
//  Place.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/9/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WebLink;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * placeName;
@property (nonatomic, retain) NSString * addressFormatted;
@property (nonatomic, retain) NSString * placeType;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * hoursInfo;
@property (nonatomic, retain) NSString * reservationInfo;
@property (nonatomic, retain) NSString * reviewInfo;
@property (nonatomic, retain) NSString * noteInfo;
@property (nonatomic, retain) NSNumber * updateGeneration;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * miscInfo;
@property (nonatomic, retain) NSNumber * uploaded;
@property (nonatomic, retain) NSNumber * geocoded;
@property (nonatomic, retain) NSSet *relatedLinks;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addRelatedLinksObject:(WebLink *)value;
- (void)removeRelatedLinksObject:(WebLink *)value;
- (void)addRelatedLinks:(NSSet *)values;
- (void)removeRelatedLinks:(NSSet *)values;

@end
