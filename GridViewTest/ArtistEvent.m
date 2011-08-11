//
//  ArtistEvent.m
//  MusicBrowser
//
//  Created by mic on 27.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArtistEvent.h"


@implementation ArtistEvent

@synthesize title, artists, venue, city, country, url, eventId, date;


- (void)dealloc {
    [title release];
    [artists release];
    [venue release];
    [city release];
    [country release];
    [url release];
    [eventId release]; 
    [date release];
    [super dealloc];
}

@end
