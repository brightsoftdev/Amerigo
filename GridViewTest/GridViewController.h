//
//  GridViewController.h
//  GridViewTest
//
//  Created by mic on 15.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDGridView.h"
#import "Artist.h"
#import "TopBarViewController.h"
#import "Utilities.h"

@interface GridViewController : UIViewController <BDGridViewDelegate, BDGridViewDataSource> {

    NSMutableArray* artists;
    NSMutableDictionary* images;    
    NSMutableDictionary* cellViews;
    Artist* selectedArtist;
}

@property (nonatomic, retain) NSMutableArray* artists;
@property (nonatomic, retain) Artist* selectedArtist;
@property (retain, nonatomic) IBOutlet BDGridView *gridView;

- (void) imageLoaded:(UIImage *)img forIdString:(NSString *)idString;
- (void) artistsLoaded:(NSArray*) simArtists;

- (UIImage*)imageWithBorderFromImage:(UIImage*)source;
- (void) reloadGridView;

@end
