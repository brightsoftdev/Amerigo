//
//  ArtistImage.m
//  MusicBrowser
//
//  Created by mic on 20.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArtistImage.h"


@implementation ArtistImage

@synthesize title, urlLarge, urlMedium, urlSmallSquare, index, sizeLarge, sizeMedium, sizeSmallSquare;


- (id)copyWithZone:(NSZone *)zone
{
    ArtistImage* copy = [[[self class] allocWithZone:zone] init];
    
    copy.title = self.title;
    copy.urlLarge = urlLarge;
    copy.urlMedium = urlMedium;
    copy.urlSmallSquare = urlSmallSquare;
    copy.index = index;    
	copy.sizeLarge = sizeLarge;
	copy.sizeSmallSquare = sizeSmallSquare;
	copy.sizeMedium = sizeMedium;
    return copy;
}

- (void)dealloc {
    [title release];
    [urlLarge release];
    [urlMedium release];
    [urlSmallSquare release];
    [super dealloc];
}

@end
