//
//  GridViewController.h
//  GridViewTest
//
//  Created by mic on 15.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQGridViewController.h"
#import "Artist.h"
#import "TopBarViewController.h"
#import "Utilities.h"

@interface GridViewController : AQGridViewController {

    NSMutableArray* artists;
    NSMutableDictionary* images;
    NSMutableDictionary* cellViews;
    Artist* selectedArtist;
}

@property (nonatomic, retain) NSMutableArray* artists;
@property (nonatomic, retain) Artist* selectedArtist;

- (void) imageLoaded:(UIImage *)img forIdString:(NSString *)idString;
- (void) artistsLoaded:(NSArray*) simArtists;

@end
