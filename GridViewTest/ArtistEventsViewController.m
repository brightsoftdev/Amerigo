//
//  ArtistEventsViewController.m
//  MusicBrowser
//
//  Created by mic on 27.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArtistEventsViewController.h"

@implementation ArtistEventsViewController
@synthesize webView;
@synthesize newsWebView;

Artist* selectedArtist;

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
        //load artist events
        dispatch_async(
           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               //do task
               ArtistDBConnector* con = [[[ArtistDBConnector alloc] init] autorelease];             
               Artist* a = [con loadEventsForArtist:artist];                   
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   //task done
                   [self artistEventsLoaded:a];                
               });
           });
    }
}

- (void) updateWebView {
    NSString* html = @"<html><header><style> a {color: #222222;} .toptitle { font-size:32px; } .title { font-size:22px; } .underline{ border:none; border-bottom: 1px solid #AAAAAA; } .title2 { font-size:14px; } .subtitle { font-size: 12px; } body {font-family:Helvetica; background-color:transparent; font-size:17px;} </style></header><body> <span class=\"toptitle\">Events</span> <span class=\"subtitle\">(<a href=\"http://www.lastfm.de\">last.fm</a>)</span> <p></p> <table>";
    if (selectedArtist && selectedArtist.events) {
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"EEE dd.MM.yyyy"];

        for (ArtistEvent* evt in selectedArtist.events) {
            //Date, city, country
            html = [html stringByAppendingFormat:@"<tr><td class=\"underline\"><span class=\"title\">%@</span> <br/> <span class=\"title2\">%@, %@</span></td></tr>", [df stringFromDate:evt.date], evt.city, evt.country];
            //venue
            html = [html stringByAppendingFormat:@"<tr><td> <a href=\"%@\"> %@ </a> </td></tr>", evt.url, evt.venue];            
            //artists
            if (evt.artists && [evt.artists count] > 0) {
                NSString* s = @"";
                for (NSString* a in evt.artists) {
                    s = [s stringByAppendingFormat:@"%@, ", a];
                }
                s = [s substringToIndex:[s length] -2];
                html = [html stringByAppendingFormat:@"<tr><td class=\"subtitle\">%@</td></tr>", s];  
            }
            html = [html stringByAppendingString:@"<tr><td><br/><br/></td></tr>"];
        }
        [df release];
    }
    html = [html stringByAppendingString:@"</table></body></htm>"];
    
    [self.webView loadHTMLString:html baseURL:nil];
}

- (void) updateNewsView {
    NSString* html = @"<html><header><style> a {color: #222222;} .toptitle { font-size:32px; } .title { font-size:19px; } .underline{ border:none; border-bottom: 1px solid #AAAAAA; } .title2 { font-size:14px; } .subtitle { font-size: 12px; } body {font-family:Helvetica; background-color:transparent; font-size:17px;} </style></header><body> <span class=\"toptitle\">News</span> <span class=\"subtitle\">(<a href=\"http://www.echonest.com\">echonest,com</a>)</span> <p></p> <table>";
    if (selectedArtist && selectedArtist.news) {        
        for (ArtistNews* news in selectedArtist.news) {
            //title
            html = [html stringByAppendingFormat:@"<tr><td class=\"underline\"><span class=\"title\">%@</span></td></tr>", news.title];
            //summary
            html = [html stringByAppendingFormat:@"<tr><td>%@</td></tr>", news.summary];
            //URL
            html = [html stringByAppendingFormat:@"<tr><td><a href=\"%@\">Read more...</a></td></tr>", news.url];
            html = [html stringByAppendingString:@"<tr><td><br/><br/></td></tr>"];
        }
    }
    html = [html stringByAppendingString:@"</table></body></htm>"];
    [self.newsWebView loadHTMLString:html baseURL:nil];
}



- (void) artistEventsLoaded:(Artist*)a 
{
    selectedArtist = nil;
    selectedArtist = [a retain];
    
    [self updateWebView];    
    [self updateNewsView];
}


#pragma mark - WebViewDelegate methodes

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    //open links in safari
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}


#pragma mark - memory management

- (void)dealloc
{
    [selectedArtist dealloc];
    [webView release];
    [newsWebView release];
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

    self.webView.delegate = self;
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self.webView setOpaque:NO];
    [self updateWebView];
    
    self.newsWebView.delegate = self;
    [self.newsWebView setBackgroundColor:[UIColor clearColor]];
    [self.newsWebView setOpaque:NO];
    [self updateNewsView];

    
    //TODO on click on link ask the user to open the link in safari
    
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setNewsWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
