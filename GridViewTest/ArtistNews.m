//
//  ArtistNews.m
//  MusicBrowser
//
//  Created by mic on 28.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArtistNews.h"


@implementation ArtistNews

@synthesize title, url, summary;

- (void)dealloc {
    [title release];
    [url release];
    [summary release];
    [super dealloc];
}

@end
