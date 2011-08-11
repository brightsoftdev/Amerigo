//
//  EchoNestConnector.m
//  GridViewTest
//
//  Created by mic on 16.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EchoNestConnector.h"

@implementation EchoNestConnector

//NSString* const APIKEY = @"KTEDNCX2Y8YWQXPF5";
//NSString* const APIKEY = @"N6E4NIOVYMTHNDM8J";
NSString* const APIKEY = @"ZZRHCSPWNBCSWMHE0";

NSString* const LIC = @"unknown";
int start = 0;
int result = 16;

@synthesize delegate;


- (void) loadImageUrlsForArtistWithId:(NSString*) artistId count:(int)count start:(int)start
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;

    NSString* u = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/artist/images?api_key=%@&id=%@&format=json&results=%i&start=%i&license=%@", APIKEY, artistId, count, start, LIC];    
    
    // Create NSURL string from formatted string
    NSURL *url = [NSURL URLWithString:u];
    
    // Setup and start async download
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
    
    LoadArtistImageHandler* handler = [[LoadArtistImageHandler alloc] init];
    handler.delegate = self.delegate;
    handler.artistId = artistId;
    
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:handler];
    [con release];
    [request release];        
}

- (void) loadArtistWithName:(NSString*) name 
{
    if(name == nil) {
        return;
    }
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    
    //escape seach name
    NSString *escapedName = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //build url
    NSString* u = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/artist/search?api_key=%@&name=%@&format=json&results=%i&start=%i&bucket=id:7digital&bucket=id:musicbrainz", APIKEY, escapedName, 1, 0];
    NSLog(@"URL: %@", u);
    
    // Create NSURL string from formatted string
    NSURL *url = [NSURL URLWithString:u];
    
    // Setup and start async download
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
    
    //create connection and load data asynchronous
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [con release];
    [request release];    

    
}

- (void) loadArtistsSimilarToArtistWithName:(NSString*) name count:(int) count start:(int) start 
{
    if(name == nil) {
        return;
    }
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    
    //escape seach name
    NSString *escapedName = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //build url
    NSString* u = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/artist/similar?api_key=%@&name=%@&format=json&results=%i&start=%i&bucket=id:7digital&bucket=id:musicbrainz", APIKEY, escapedName, count, start];
    NSLog(@"URL: %@", u);
    
    // Create NSURL string from formatted string
    NSURL *url = [NSURL URLWithString:u];
    
    // Setup and start async download
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
    
    //create connection and load data asynchronous
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [con release];
    [request release];    
}

#pragma mark - handling connection result

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData 
{
	if (data == nil) { 
        data = [[NSMutableData alloc] initWithCapacity:2048]; 
    }    
    
	[data appendData:incrementalData];
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection 
{
	//so self data now has the complete image 
	[connection release];
	connection=nil;

   
    // Store incoming data into a string
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Create a dictionary from the JSON string
    NSDictionary *results = [jsonString JSONValue];
    
    if ([[results objectForKey:@"response"] objectForKey:@"images"]) {
        NSMutableArray* items = [[NSMutableArray alloc] init];
        // Build an array from the dictionary for easy access to each entry
        NSArray *photos = [[results objectForKey:@"response"] objectForKey:@"images"];

        // Loop through each entry in the dictionary...
        for (NSDictionary *photo in photos) {
            NSString *photoURLString = [photo objectForKey:@"url"];
            [items addObject:photoURLString];
        } 
        
        if (delegate) {
            [delegate photosLoaded:items];
        }        
    }
    else if ([[results objectForKey:@"response"] objectForKey:@"artists"]) {
        NSArray *artists = [[results objectForKey:@"response"] objectForKey:@"artists"];
        NSMutableArray* items = [[[NSMutableArray alloc] init] autorelease];
        for (NSDictionary *a in artists) {
            NSString *name = [a objectForKey:@"name"];
            NSString *aid = [a objectForKey:@"id"];

            //get 7 digital id and musicbrainz id
            NSArray* foreignIds = [a objectForKey:@"foreign_ids"];
            NSDictionary* foreignId = [foreignIds objectAtIndex:0];
            NSString *said7d = [foreignId objectForKey:@"foreign_id"];
            int aid7d = [[said7d substringFromIndex:16] intValue];
            NSString* saidmb = [foreignId objectForKey:@"foreign_id"];
            NSString* aidmb = [saidmb substringFromIndex:19];

            //create the artist object
            Artist* art = [[Artist alloc] init];
            art.name = name;
            art.artistId = aid;
            art.artistId7d = aid7d;
            art.artistIdMB = aidmb;
            [items addObject:art];
            
            //load the artist image url
            [self loadImageUrlsForArtistWithId:aid count:1 start:0];  
        }
        
        if (delegate) {
            [delegate artistsLoaded:items];
        }
    }
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}


- (void)dealloc {
    [connection cancel];
    [connection release];
    [data release];
    [delegate release];
    [super dealloc];
}

@end
