//
//  GridViewController.m
//  GridViewTest
//
//  Created by mic on 15.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GridViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ArtistDBConnector.h"
#import "ArtistInfoViewController.h"
#import "GridViewTestAppDelegate.h"
#import "Utilities.h"

@implementation GridViewController

@synthesize artists, selectedArtist;

#define CELL_WIDTH 220
#define CELL_HEIGHT 160
#define BG_GRAY_VALUE 5

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gridView.scrollEnabled = false;
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.gridView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    
    //init some data structures
    self.artists = [[NSMutableArray alloc] init];
    cellViews = [[NSMutableDictionary alloc] init];
    images = [[NSMutableDictionary alloc] init];
    
    // Register observer to be notified when artist is loaded
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(artistLoaded:) 
                                                 name:@"ArtistLoaded" object:nil];   
}


//called when the artist for the top bar is loaded
- (void) artistLoaded:(NSNotification*) notification 
{
    //change artist name in top bar
    Artist* artist = notification.object;
    if (artist) {
        selectedArtist = [artist retain];
        self.title = artist.name;    
        
        //load similar artists
        dispatch_async(
           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               //do task
               ArtistDBConnector* con = [[ArtistDBConnector alloc] init];
               NSArray* simArtists = [con loadArtistsSimilarToArtist:artist];
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   //task done
                   [self artistsLoaded:simArtists];
                   [con release];
               });
           });        
    } 
    else {
        self.title = @"";
        selectedArtist = nil;
    }
    
}



//loads the images for the artists array
-(void) loadImagesForArtists:(NSArray*) data 
{
    if (data) {
        for (Artist* a in data) {
            //only load image if it's not already loaded
            if ([images objectForKey:a.artistIdMB] == nil) {
                [NSThread detachNewThreadSelector:@selector(loadImageForTableForArtist:)
                                         toTarget:self 
                                       withObject:a];                
            }
        }
    }
}

//loads the image for the artist
-(void) loadImageForTableForArtist:(Artist*) a 
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (a) {
        UIImage* img = [Utilities imageForUrl:a.imgUrl];
        if (img) {
            [self imageLoaded:img forIdString:a.artistIdMB];
        }
    }
    [pool release];
}


//called when the artist for the top bar is loaded
- (void) artistsLoaded:(NSArray*) simArtists
{
    //deselect objects
    if (self.artists) {
        int count = [self.artists count];
        for (int i=0; i<count; i++) {
            [self.gridView deselectItemAtIndex:i animated:true];
        }
    }
    
    //remove all data
    [self.artists removeAllObjects];
    [self.gridView reloadData];
    [self.gridView setNeedsDisplay];

    [images removeAllObjects];
    [cellViews removeAllObjects];

    [self.artists addObjectsFromArray:simArtists];
    [self.gridView reloadData];        

    [self loadImagesForArtists:self.artists];
}


//called when a grid image has been loaded and should be diplayed in the table
- (void)imageLoaded:(UIImage *)img forIdString:(NSString *)idString 
{
    if (img) {
        [images setObject:img forKey:idString];

        NSNumber* idx = [cellViews valueForKey:idString];
        if (idx) {
            AQGridViewCell* cellView = [self.gridView cellForItemAtIndex:[idx intValue]];
            if (cellView) {
                UIImageView* imgView = (UIImageView*) [cellView.contentView viewWithTag:999];
                if (imgView) {
                    [Utilities setNewImageOfImageView:imgView newImage:img];
                }  
            }
        }        
    }
}

#pragma mark - GridViewController methods


- (void)gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index 
{
    Artist* artist = [self.artists objectAtIndex:index];
    if (artist) {
        GridViewTestAppDelegate* del = (GridViewTestAppDelegate*) [[UIApplication sharedApplication] delegate];
        [del performSearch:artist.name];
    }
}

-(CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView {
    return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index {
    static NSString * PlainCellIdentifier = @"PlainCellIdentifier";
    
    Artist* artist = [self.artists objectAtIndex:index];
    
    if (artist) {
        [cellViews setObject:[NSNumber numberWithInt:index] forKey:artist.artistId];
    }

    AQGridViewCell * plainCell = (AQGridViewCell *)[gridView dequeueReusableCellWithIdentifier: PlainCellIdentifier];
    UIImageView* imgView = nil;
    UILabel* lbl = nil;
    
    if ( plainCell == nil ) {
        plainCell = [[[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, CELL_WIDTH, CELL_HEIGHT)                                                     
                                                  reuseIdentifier: PlainCellIdentifier] autorelease];
        plainCell.selectionStyle = AQGridViewCellSelectionStyleGray;
    }
    else {
        imgView = (UIImageView*) [plainCell.contentView viewWithTag:999];
        [imgView removeFromSuperview];
        imgView = nil;
        
        lbl = (UILabel*) [plainCell.contentView viewWithTag:998];
        [lbl removeFromSuperview];
        lbl = nil;
    }
    
    CGRect frame = CGRectMake(10, 5, 200, 120);    
        
    //create image view
    if (imgView == nil) {
        imgView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
        imgView.image = [UIImage imageNamed:@"noimage.png"];
        imgView.tag = 999;
        
        //add imageview to cell
        [plainCell.contentView addSubview:imgView];
    }
    
    //try to set image for artist (if already loaded)
    if ([images objectForKey:artist.artistId]) {
        UIImage* img = [images objectForKey:artist.artistId];
        imgView.image = img;
    }
    
    //create artist label
    if (lbl == nil) {
        lbl = [[[UILabel alloc] initWithFrame:CGRectMake(0, CELL_HEIGHT - 40, CELL_WIDTH, 40)] autorelease];
        lbl.minimumFontSize = 10;
        lbl.adjustsFontSizeToFitWidth = true;
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.font = [UIFont fontWithName:@"Times New Roman" size:20];
        lbl.tag = 998;
        
        lbl.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        lbl.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        lbl.layer.shadowRadius = 8.0;
        lbl.layer.shadowOpacity = 0.75;

        lbl.layer.masksToBounds = NO;

        
        //and add it to the grid cell view
        [plainCell.contentView addSubview:lbl];
    }
    //set label name
    lbl.text = artist.name;
    lbl.textColor = [UIColor darkTextColor];

//    float f = (float) BG_GRAY_VALUE/255;
//    UIColor* bgClr = [UIColor colorWithRed:f green:f blue:f alpha:1.0];
    UIColor* bgClr = [UIColor clearColor];

    plainCell.backgroundColor = bgClr;
    plainCell.contentView.backgroundColor = bgClr;
    imgView.backgroundColor = bgClr;        
    lbl.backgroundColor = bgClr;

    return plainCell;
}

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView {
    if (artists) {
        return [artists count];
    } else {
        return 0;
    }
}


- (void)dealloc {
    //remove obervers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ArtistsLoaded" object:nil];    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ArtistLoaded" object:nil];
    [selectedArtist release];
    [images release];
    [artists release];
    [cellViews release];
    [super dealloc];
}

@end
