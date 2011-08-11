//
//  ArtistDBConnector.h
//  GridViewTest
//
//  Created by mic on 17.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Artist.h"
#import "ArtistImage.h"
#import "ArtistSong.h"
#import "ArtistEvent.h"
#import "ArtistNews.h"
#import "DDXML.h"

@interface ArtistDBConnector : NSObject {
    NSMutableDictionary* artists;
}

@property (nonatomic, retain) NSMutableDictionary* artists;

-(NSArray*) loadArtistsSimilarToArtist:(Artist*) artist;

-(void) loadArtistForName:(NSString*) name;

//load the news entries for the artist
- (Artist*) loadNewsForArtist:(Artist*)artist;

//load events for the artist
- (Artist*) loadEventsForArtist:(Artist*) artist;

//load images (description) for the artist
- (Artist*) loadImagesForArtist:(Artist*) artist;

//load songs (description) for the artist
- (Artist*) loadSongsForArtist:(Artist*) artist;

//loads the UIImage for the specified URL
- (UIImage*) loadImageForUrl:(NSString*)surl;

@end
