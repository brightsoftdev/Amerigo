//
//  ArtistInfoImageGridController.h
//  MusicBrowser
//
//  Created by mic on 20.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQGridViewController.h"
#import "Artist.h"
#import "ArtistImage.h"
#import "BasicPreviewItem.h"
#import "ImagePreviewController.h"
#import "Utilities.h"

@interface ArtistInfoImageGridController : AQGridViewController {
    NSMutableArray* artistImages;
    NSMutableArray* images;
	UIPopoverController* popCtl;
    Artist* selectedArtist;
    BOOL needsToLoadImages;
    BOOL isViewVisible;
}

@property (nonatomic, retain) NSMutableArray* artistImages;
@property (nonatomic, retain) NSMutableArray* images;
@property (nonatomic, retain) Artist* selectedArtist;

- (void) updateImage:(UIImage*)img forKey:(ArtistImage*)aimg;

- (void) artistImagesLoaded:(Artist*)artist;

@end
