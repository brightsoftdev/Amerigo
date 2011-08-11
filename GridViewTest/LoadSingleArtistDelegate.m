//
//  LoadSingleArtistDelegate.m
//  GridViewTest
//
//  Created by mic on 17.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadSingleArtistDelegate.h"


@implementation LoadSingleArtistDelegate

- (void)artistsLoaded:(NSArray *)data {
    for (Artist* a in data) {
        //fire notification event
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ArtistLoaded" object:a];
    }
}

-(void)photosLoaded:(NSArray *)urls {
}

- (void) imageUrlChangedForArtistId:(NSString*)artistId url:(NSString*)urlString {    
    //load the image
    ImageLoader* loader = [[[ImageLoader alloc] init] autorelease];
    loader.delegate = self;
    loader.imgUrl = urlString;
    loader.idString = artistId;
    [loader start];
}

- (void)imageLoaded:(UIImage *)img forIdString:(NSString *)idString 
{
    NSLog(@"ArtistImageLoaded");
    //fire notification event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ArtistImageLoaded" object:img];
}

@end
