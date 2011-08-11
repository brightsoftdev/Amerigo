//
//  ArtistSong.h
//  MusicBrowser
//
//  Created by Michael Anteboth on 23.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ArtistSong : NSObject {
	NSString* title;
	NSString* url;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* url;

@end
