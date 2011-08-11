//
//  ArtistSong.m
//  MusicBrowser
//
//  Created by Michael Anteboth on 23.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArtistSong.h"


@implementation ArtistSong

@synthesize title, url;


- (void) dealloc
{
	[url release];
	[title release];
	[super dealloc];
}


@end
