//
//  Artist.m
//  GridViewTest
//
//  Created by mic on 16.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Artist.h"


@implementation Artist

@synthesize name, artistId, artistId7d, artistIdMB, imgUrl, bioContent, bioSummary, url, tags, images, songs, events, news;



- (void)dealloc {
	[songs release];
    [images release];
    [tags release];
    [imgUrl release];
    [bioSummary release];
    [bioContent release];
    [artistIdMB release];
    [artistId release];
    [name release];
    [url release];
    [events release];
    [news release];
    [super dealloc];
}

@end
