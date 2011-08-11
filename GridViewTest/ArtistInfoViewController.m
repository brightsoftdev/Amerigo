//
//  ArtistInfoViewController.m
//  GridViewTest
//
//  Created by mic on 18.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArtistInfoViewController.h"
#import "GridViewTestAppDelegate.h"

@implementation ArtistInfoViewController


@synthesize imageGridViewController;
@synthesize biographyWebView;

NSString* header0 = @"<html><header><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">";
NSString* header1 = @"<style> body {background-color:transparent; font-size:17px;} h1 {font-family:Helvetica;} pre { font-family:Helvetica; text-align:justify; white-space:pre-line; color: #222222; } a {color: #222222;} </style></header><body><h1>Biographie</h1> <pre>";
NSString* footer = @"</pre></body></html>";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Register observer to be notified when artist is loaded
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(artistLoaded:) 
                                                     name:@"ArtistLoaded" object:nil];    
    }
    return self;
}

- (void) artistLoaded:(NSNotification*) notification 
{
    Artist* artist = notification.object;
    if (artist) {     
        selectedArtist = [artist retain];
        //build html string
        NSString* html = [NSString stringWithFormat:@"%@%@%@%@", header0, header1, artist.bioContent, footer];        
        //set html string in webview
        [self.biographyWebView loadHTMLString:html baseURL:nil];
    }
}

#pragma mark - memory management

- (void)dealloc
{
    [selectedArtist release];
    [biographyWebView release];
    [imageGridViewController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    [self.biographyWebView setBackgroundColor:[UIColor clearColor]];
    [self.biographyWebView setOpaque:NO];

    NSString* bio = nil;
    if (selectedArtist) bio = selectedArtist.bioContent;
    else bio = @"";
    //build html string
    NSString* html = [NSString stringWithFormat:@"%@%@%@%@", header0, header1, bio, footer];        
    //set html string in webview
    [self.biographyWebView loadHTMLString:html baseURL:nil];
}

- (void)viewDidUnload
{
    [self setBiographyWebView:nil];
    [self setImageGridViewController:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
