//
//  EchoNestDelegate.h
//  GridViewTest
//
//  Created by mic on 16.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


@protocol EchoNestDelegate <NSObject>

- (void) photosLoaded:(NSArray*) urls;
- (void) artistsLoaded:(NSArray*) data;
- (void) imageUrlChangedForArtistId:(NSString*)artistId url:(NSString*)urlString;

@end