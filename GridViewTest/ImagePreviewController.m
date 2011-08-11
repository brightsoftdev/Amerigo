//
//  ImagePreviewController.m
//  MusicBrowser
//
//  Created by mic on 22.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImagePreviewController.h"

@implementation ImagePreviewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	[imageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	imageView.image = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void) viewDidDisappear:(BOOL)animated
{
	//[imageView.image release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (void) showImage:(ArtistImage*) artistImage {
	
	if (!artistImage) {
		return;
	}
	
	NSString* urlString = nil;
	float max = MAX(artistImage.sizeMedium.width, artistImage.sizeMedium.height);
	if (max > 500) {
		urlString = artistImage.urlMedium;
	} else {
		urlString = artistImage.urlLarge;	
	}

    if (imageView) {
        [imageView.image release];        
        [imageView release];
        imageView = nil;
    }
    
	imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noimage_600x600.png"]];
	imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	[self.view addSubview:imageView];
	
	
	dispatch_async(
		dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			//do task, load the image
			ArtistDBConnector* con = [[ArtistDBConnector alloc] init];
			UIImage* img = [con loadImageForUrl:urlString];
			[con release];		
					   
			dispatch_async(dispatch_get_main_queue(), ^{
				//task done, display the image
				if (img) {
					[Utilities setNewImageOfImageView:imageView newImage:img];
				}	
			});
	});
}

@end
