//
//  Artist.h
//  GridViewTest
//
//  Created by mic on 16.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Artist : NSObject {
    NSString* name;
    NSString* artistId;
    NSString* artistIdMB;    
    int artistId7d;
    NSString* imgUrl;
    NSString* bioSummary;
    NSString* bioContent;
    NSString* url;
    NSArray* tags;
    NSArray* images;
	NSArray* songs;
	NSArray* events;
  	NSArray* news;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* artistId;
@property (nonatomic, retain) NSString* artistIdMB;
@property (nonatomic, retain) NSString* imgUrl;
@property (nonatomic, retain) NSString* bioSummary;
@property (nonatomic, retain) NSString* bioContent;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSArray* tags;
@property (nonatomic, retain) NSArray* images;
@property (nonatomic, retain) NSArray* songs;
@property (nonatomic, retain) NSArray* events;
@property (nonatomic, retain) NSArray* news;

@property int artistId7d;

@end
