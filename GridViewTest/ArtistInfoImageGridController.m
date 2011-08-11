//
//  ArtistInfoImageGridController.m
//  MusicBrowser
//
//  Created by mic on 20.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArtistInfoImageGridController.h"


@implementation ArtistInfoImageGridController

@synthesize images, artistImages, selectedArtist;


- (id)init {
    self = [super init];
    if (self) {
        needsToLoadImages = true;
        isViewVisible = false;
        self.images = [[NSMutableArray alloc] init];
        self.artistImages = [[NSMutableArray alloc] init];
        // Register observer to be notified when artist is loaded
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(artistLoaded:) 
                                                     name:@"ArtistLoaded" object:nil];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}


//loads and displays the images for the selected artist
- (void) loadAndDisplayImagesForSelectedArtist
{
    //now load the real image one-by-one asynchronous
    //this should only be done if the artist has changed
    if (needsToLoadImages) {
        needsToLoadImages = false;
        int idx = 0;
        for (ArtistImage* aimg in selectedArtist.images) {
            aimg.index = idx;
            idx++;            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //do task
                ArtistDBConnector* con = [[[ArtistDBConnector alloc] init] autorelease];
                UIImage* img = [con loadImageForUrl:aimg.urlSmallSquare];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //task done
                    [self updateImage:img forKey:aimg];
                });
            });
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isViewVisible = true;
    //start loading and displaying the images for the artist
    [self loadAndDisplayImagesForSelectedArtist];
}

- (void)viewWillDisappear:(BOOL)animated
{
    isViewVisible = false;
    [super viewWillDisappear:animated];
}


- (void)dealloc {
    [selectedArtist release];
    [artistImages release];
	[popCtl release];
    [images release];
    [super dealloc];
}

- (void) artistLoaded:(NSNotification*) notification 
{
    //clear cached data
    [self.artistImages removeAllObjects];
    [self.images removeAllObjects];
    
    //TODO only load images if this view is visible
    Artist* artist = notification.object;
    selectedArtist = artist;
    needsToLoadImages = true;
    if (artist) {             
        //load additional images
        dispatch_async(
           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               //do task
               ArtistDBConnector* con = [[[ArtistDBConnector alloc] init] autorelease];             
               Artist* a = [con loadImagesForArtist:artist];                   
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   //task done
                   [self artistImagesLoaded:a];                
               });
           });
    } else {
        //TODO clear grid view
    }
}


-(void) updateImage:(UIImage*)img forKey:(ArtistImage*)aimg 
{
    if (img) {
        [self.images replaceObjectAtIndex:aimg.index withObject:img];   
    }
    
	AQGridViewCell* cell = [self.gridView cellForItemAtIndex:aimg.index];
    UIImageView* imgView = (UIImageView*) [cell.contentView viewWithTag:999];
	[Utilities setNewImageOfImageView:imgView newImage:img];	
}

- (void) artistImagesLoaded:(Artist*)artist
{
    if (artist) 
    {
        //create dummy entries for each image item
		NSMutableArray* tmp = [[NSMutableArray alloc] init];
		UIImage* dummy = [UIImage imageNamed:@"noimage.png"];
		for (ArtistImage* aimg in artist.images) {
            [tmp addObject:dummy];
            [artistImages addObject:aimg];
		}                
		self.images = tmp;
        [tmp release];
        
        //reload the table
		[self.gridView reloadData];
        
        if (isViewVisible) {
            [self loadAndDisplayImagesForSelectedArtist];            
        }

    }
}


#pragma mark - grid view methods

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView 
{
    return [self.images count];
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView 
{
    return CGSizeMake(120, 125);
}


- (NSUInteger) gridView:(AQGridView *)gridView willSelectItemAtIndex:(NSUInteger)index
{

	//create popover controller if not done yet
	if (popCtl != nil) {
		[popCtl release];
		popCtl = nil;
	}
	
	ArtistImage* artistImage = [self.artistImages objectAtIndex:index];
	
	//compute the aspect ratio preserved image view size
	CGSize size = artistImage.sizeMedium;
	float aspectRatio = size.width / size.height;
	float d = 600; //längste kantenlänge
	float w = 0, h = 0;
	if (size.width > size.height) {
		w = d;
		h = size.height / size.width * d;
	} else {
		h = d;
		w = d * aspectRatio;
	}
		
	//create content of popover (image view controller)
	ImagePreviewController* viewCtl = [[ImagePreviewController alloc] initWithNibName:@"ImagePreview" bundle:nil];
	viewCtl.view.frame = CGRectMake(0, 0, w, h);
	viewCtl.contentSizeForViewInPopover = CGSizeMake(w, h);
		
	popCtl = [[UIPopoverController alloc] initWithContentViewController:viewCtl];
		
	[viewCtl release];	
	

	//show image item
	[viewCtl showImage:artistImage];

	//get rect for selected cell
	CGRect cell = [self.gridView rectForItemAtIndex:index];
	
	//show popover controller
    [popCtl presentPopoverFromRect:cell inView:self.view
	   permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
	
	return index;
}


#define CELL_WIDTH 120
#define CELL_HEIGHT 120
#define BG_GRAY_VALUE 5

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index {
    static NSString * PlainCellIdentifier = @"PlainCellIdentifier";
    
    AQGridViewCell * plainCell = (AQGridViewCell *)[gridView dequeueReusableCellWithIdentifier: PlainCellIdentifier];
    UIImageView* imgView = nil;
    
    if ( plainCell == nil ) {
        plainCell = [[[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, CELL_WIDTH, CELL_HEIGHT)                                                     
                                           reuseIdentifier: PlainCellIdentifier] autorelease];
        plainCell.selectionStyle = AQGridViewCellSelectionStyleGray;
    }
    else {
        imgView = (UIImageView*) [plainCell.contentView viewWithTag:999];
        [imgView removeFromSuperview];
        imgView = nil;
    }
    
    CGRect frame = CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT);    
    
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
    
    //try to set image (if already loaded)
    UIImage* img = [self.images objectAtIndex:index];
    if (img) {
        imgView.image = img;
    }
        
    //set bg color to clear
    UIColor* bgClr = [UIColor clearColor];    
    plainCell.backgroundColor = bgClr;
    plainCell.contentView.backgroundColor = bgClr;
    imgView.backgroundColor = bgClr;        
    
    return plainCell;
}

@end
