//
//  ArtistNews.h
//  MusicBrowser
//
//  Created by mic on 28.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ArtistNews : NSObject {
    NSString* title;
    NSString* url;
    NSString* summary;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* summary;

@end
