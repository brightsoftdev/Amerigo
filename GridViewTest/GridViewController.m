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
#import "ImageCellView.h"
#import "UIImage+scaleImage.h"

@implementation GridViewController
@synthesize gridView;

@synthesize artists, selectedArtist;

#define CELL_WIDTH 220
#define CELL_HEIGHT 180
#define BG_GRAY_VALUE 5

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gridView.gridViewDelegate = self;
    self.gridView.dataSource = self;
    
    self.gridView.topContentPadding = 30.0f;
   
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
//        int count = [self.artists count];
//        for (int i=0; i<count; i++) {
//            [self.gridView deselectItemAtIndex:i animated:true];
//        }
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
        //store the image in the images cache
        [images setObject:img forKey:idString];

        //update the corresponding grid cell with the loaded image
        ImageCellView* cell = [cellViews valueForKey:idString];
        if (cell) {
            UIImageView* imgView = cell.imageView;
            UIImage* img2 = [self imageWithBorderFromImage:img];
            [Utilities setNewImageOfImageView:imgView newImage:img2];
        }        
    }
}

- (void) reloadGridView
{
    [self.gridView reloadData];
}


#pragma mark - BDGridView methods

- (BDGridCell *)gridView:(BDGridView *)gridView cellForIndex:(NSUInteger)index
{
    //get the artist for the cell index
    Artist* artist = [self.artists objectAtIndex:index];
    
    //get the cell view, create a new one if we don't get a cached cell
    ImageCellView* cell = (ImageCellView*) [self.gridView dequeueCell];
    if (cell == nil) {
        cell = [[ImageCellView alloc] initWithStyle:BDGridCellStyleDefault];                
    }
    
    //reset to desected
    cell.selected = false;
    
    //set cell inset
    cell.contentInset = UIEdgeInsetsMake(5, 0, 0, 5);
    //set the captions label shadow color
    cell.label.shadowColor = [UIColor lightTextColor];
    
    //we need to get the cell for the artistID later to update the cell image when it's loaded
    //so store the cell in the disctionary
    if (artist) {
        [cellViews setObject:cell forKey:artist.artistId];
    }
    
    //get the cells image view
    UIImageView* imgView = (UIImageView*) cell.imageView;
    //set mode to aspect fit
    imgView.contentMode = UIViewContentModeScaleAspectFit;
        
    //try to set image for artist (if already loaded)
    if ([images objectForKey:artist.artistId]) {
        UIImage* img = [images objectForKey:artist.artistId];
        img = [self imageWithBorderFromImage:img];
        cell.image = img;
    }
    else {
        //use dummy image if artist image is not loaded yet
        cell.image = [UIImage imageNamed:@"noimage.png"];        
    }
    
    //set the artist name as cell caption
    cell.caption = artist.name;
    
    return cell;
}

- (UIImage*)imageWithBorderFromImage:(UIImage*)source
{
    //max size for image
    CGSize kMaxImageViewSize = {.width = 170, .height = 170};
    
    //calc scaled size
    CGSize imageSize = source.size;
    CGFloat aspectRatio = imageSize.width / imageSize.height;
    CGRect frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    if (kMaxImageViewSize.width / aspectRatio <= kMaxImageViewSize.height) {
        frame.size.width = kMaxImageViewSize.width;
        frame.size.height = frame.size.width / aspectRatio;
    } else {
        frame.size.height = kMaxImageViewSize.height;
        frame.size.width = frame.size.height * aspectRatio;
    }
   
    //get scaled image
    UIImage* scaled = [source imageByScalingProportionallyToSize:CGSizeMake(frame.size.width, frame.size.height)];    
    
    //draw white rect border
    
    int bw = 10; //border width
    CGSize size = [scaled size];
    CGSize newSize = CGSizeMake(size.width + 2*bw, size.height + 2*bw);
    
    UIGraphicsBeginImageContext(newSize);
    CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0); 
    CGContextStrokeRectWithWidth(context, rect, 2*bw);
    
    [scaled drawAtPoint:CGPointMake(bw, bw)];
        
    UIImage *testImg =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return testImg;
}


-(void)gridView:(BDGridView *)gridView didTapCell:(BDGridCell *)cell
{
    if (cell) {
        cell.selected = true;
        Artist* artist = [self.artists objectAtIndex:cell.index];
        if (artist) {
            GridViewTestAppDelegate* del = (GridViewTestAppDelegate*) [[UIApplication sharedApplication] delegate];
            [del performSearch:artist.name];
        }
    }
}

-(NSUInteger)gridViewCountOfCells:(BDGridView *)gridView
{
    if (artists) {
        return [artists count];
    } else {
        return 0;
    }
}

-(CGSize)gridViewSizeOfCell:(BDGridView *)gridView
{
    return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
}

/*
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
*/

- (void)dealloc {
    //remove obervers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ArtistsLoaded" object:nil];    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ArtistLoaded" object:nil];
    [selectedArtist release];
    [images release];
    [artists release];
    [cellViews release];
    [gridView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setGridView:nil];
    [super viewDidUnload];
}
@end
