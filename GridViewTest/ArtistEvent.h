//
//  ArtistEvent.h
//  MusicBrowser
//
//  Created by mic on 27.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ArtistEvent : NSObject {
    NSString* title;
    NSArray* artists;
    NSString* venue;
    NSString* city;
    NSString* country;
    NSString* url;
    NSString* eventId;
    NSDate* date;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSArray* artists;
@property (nonatomic, retain) NSString* venue;
@property (nonatomic, retain) NSString* city;
@property (nonatomic, retain) NSString* country;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* eventId;
@property (nonatomic, retain) NSDate* date;

@end
