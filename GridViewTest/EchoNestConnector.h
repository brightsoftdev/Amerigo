//
//  EchoNestConnector.h
//  GridViewTest
//
//  Created by mic on 16.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"
#import "Artist.h"
#import "LoadArtistImageHandler.h"
#import "EchoNestDelegate.h"


@interface EchoNestConnector : NSObject {
    id<EchoNestDelegate> delegate;

    NSURLConnection* connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData* data; //keep reference to the data so we can collect it as it downloads
}

@property (nonatomic, retain) id<EchoNestDelegate> delegate;


- (void) loadImageUrlsForArtistWithId:(NSString*) artistId count:(int)count start:(int)start;

- (void) loadArtistsSimilarToArtistWithName:(NSString*) name count:(int)count start:(int) start; 

- (void) loadArtistWithName:(NSString*) name; 

@end
