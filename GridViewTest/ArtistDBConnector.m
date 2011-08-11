//
//  ArtistDBConnector.m
//  GridViewTest
//
//  Created by mic on 17.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArtistDBConnector.h"
#import "GridViewTestAppDelegate.h"

@implementation ArtistDBConnector

@synthesize artists;

- (void)dealloc {
    [artists release];
    [super dealloc];
}

NSString* const LFM_API_KEY = @"6ff284cf32e78166cba4bd4ada9c7aef";
NSString* const ECN_API_KEY = @"KTEDNCX2Y8YWQXPF5";
NSString* const NOTIF_ArtistsLoaded = @"ArtistsLoaded";
NSString* const NOTIF_ArtistLoaded = @"ArtistLoaded";
NSString* const NOTIF_ArtistImagesLoaded = @"ArtistImagesLoaded";

NSString* const lang = @"de";

#define SIM_ARTISTS_COUNT 12




//load the events for the artist
- (Artist*) loadEventsForArtist:(Artist*) artist
{
    if (artist == nil) {
        return nil;
    }
	
	if (artist.songs != nil) {
		//songs already loaded
		return artist;
	}
    
    NSString* surl = [NSString stringWithFormat:
                      @"http://ws.audioscrobbler.com/2.0/?method=artist.getevents&api_key=%@&mbid=%@",
                      LFM_API_KEY, artist.artistIdMB];
    NSURL* url = [NSURL URLWithString:surl];
	
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return nil;
    }
    
    error = nil;
    DDXMLDocument* xmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        [xmlDoc release];
        return nil;
    }
    
    DDXMLElement* eventsElement = [[[xmlDoc rootElement] elementsForName:@"events"] objectAtIndex:0];    
    NSMutableArray* events = [[[NSMutableArray alloc] init] autorelease];        	

    //"Wed, 31 Aug 2011 20:30:00"
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSLocale* loc = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
    [df setLocale:loc];
    [df setDateFormat:@"dd MMM yyyy HH:mm:ss"];
    [loc release];
    
    NSArray* eventElements = [eventsElement elementsForName:@"event"];
    for (DDXMLElement *eventElement in eventElements) {
        NSString* eventId = [[[eventElement elementsForName:@"id"] objectAtIndex:0] stringValue];
        NSString* title = [[[eventElement elementsForName:@"title"] objectAtIndex:0] stringValue];
        NSString* url = [[[eventElement elementsForName:@"url"] objectAtIndex:0] stringValue];
        NSString* startDate = [[[eventElement elementsForName:@"startDate"] objectAtIndex:0] stringValue];
        startDate = [startDate substringFromIndex:4];
        NSDate *date = [df dateFromString:startDate];
        NSString* venue = @"";
        NSString* country = @"";
        NSString* city = @"";
        NSMutableArray* evtArtists = [[NSMutableArray alloc] initWithCapacity:0];
        
        //venue
        DDXMLElement* venueElement = [[eventElement elementsForName:@"venue"] objectAtIndex:0];
        if (venueElement) {
            venue = [[[venueElement elementsForName:@"name"] objectAtIndex:0] stringValue];
            DDXMLElement* locElement = [[venueElement elementsForName:@"location"] objectAtIndex:0];
            if (locElement) {
                city = [[[locElement elementsForName:@"city"] objectAtIndex:0] stringValue];
                country = [[[locElement elementsForName:@"country"] objectAtIndex:0] stringValue];                
            }
        }
        
        //first 10 event artists
        DDXMLElement* evtArtistsElement = [[eventElement elementsForName:@"artists"] objectAtIndex:0];
        if (evtArtistsElement) {
            int count = 0;
            NSArray* evtArtistElements = [evtArtistsElement elementsForName:@"artist"];
            for (DDXMLElement* evtArtistElement in evtArtistElements) {
                [evtArtists addObject:[evtArtistElement stringValue]];
                count++;
                if (count > 9) break;
            }
        }
        

        ArtistEvent* evt = [[ArtistEvent alloc] init];
        evt.title = title;
        evt.url = url;
        evt.date = date;
        evt.city = city;
        evt.country = country;
        evt.eventId = eventId;
        evt.venue = venue;
        evt.artists = evtArtists;
        
        [events addObject:evt];
        [evt release];
    }

    artist.events = events;
    
    [df release];
    [xmlDoc release];

    
    //load news for artist
    Artist* a = [self loadNewsForArtist:artist];
    artist.news = a.news;
    
    return artist;    
}


- (Artist*) loadNewsForArtist:(Artist*)artist 
{
    if (artist == nil) {
        return nil;
    }
	
	if (artist.songs != nil) {
		//songs already loaded
		return artist;
	}
    
    int count=15, start=0;
    NSString* aid = [NSString stringWithFormat:@"musicbrainz:artist:%@", artist.artistIdMB];
    NSString* surl = [NSString stringWithFormat:
                      @"http://developer.echonest.com/api/v4/artist/news?api_key=%@&id=%@&format=xml&results=%i&start=%i",
                      ECN_API_KEY, aid, count, start];
    NSURL* url = [NSURL URLWithString:surl];
    
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return nil;
    }
    
    error = nil;
    DDXMLDocument* xmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        [xmlDoc release];
        return nil;
    }
    
    DDXMLElement* newsRootElement = [[[xmlDoc rootElement] elementsForName:@"news"] objectAtIndex:0];    
    NSMutableArray* news = [[[NSMutableArray alloc] init] autorelease];        	
    
    NSArray* newsElements = [newsRootElement elementsForName:@"news"];
    for (DDXMLElement *newsElement in newsElements) {
        NSString* title =   [[[newsElement elementsForName:@"name"] objectAtIndex:0] stringValue];
        NSString* url =     [[[newsElement elementsForName:@"url"] objectAtIndex:0] stringValue];
        NSString* summary = [[[newsElement elementsForName:@"summary"] objectAtIndex:0] stringValue];        
        
        ArtistNews* n = [[ArtistNews alloc] init];
        n.title = title;
        n.url = url;
        n.summary = summary;
        
        [news addObject:n];
        [n release];
    }
    artist.news = news;
    
    [xmlDoc release];
    
    return artist;
}

//load song information for the artist
-(Artist*) loadSongsForArtist:(Artist*) artist
{
    if (artist == nil) {
        return nil;
    }
	
	if (artist.songs != nil) {
		//songs already loaded
		return artist;
	}
    
    int limit = 50;
    NSString* akey = [NSString stringWithFormat:@"musicbrainz:artist:%@", artist.artistIdMB];
	
    NSString* surl = [NSString stringWithFormat:
                      @"http://developer.echonest.com/api/v4/artist/audio?api_key=%@&id=%@&format=xml&results=%i&start=%i",
                      ECN_API_KEY, akey, limit, 0];
    NSURL* url = [NSURL URLWithString:surl];
	
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return nil;
    }
    
    error = nil;
    DDXMLDocument* xmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        [xmlDoc release];
        return nil;
    }
    
    DDXMLElement* audiosElement = [[[xmlDoc rootElement] elementsForName:@"audio"] objectAtIndex:0];    
    NSMutableArray* songs = [[[NSMutableArray alloc] init] autorelease];        	
		
    NSArray* audioElements = [audiosElement elementsForName:@"audio"];
    for (DDXMLElement *audioElement in audioElements) {
		NSArray* tit = [audioElement elementsForName:@"title"];
		if (tit && [tit count] > 0) {
			NSString* title = [[tit objectAtIndex:0] stringValue];
			NSArray* urls = [audioElement elementsForName:@"url"];
			if (urls && [urls count] > 0) {
				NSString* url = [[urls objectAtIndex:0] stringValue];        
		
				ArtistSong* song = [[ArtistSong alloc] init];
				song.title = title;
				song.url = url;
				[songs addObject:song];
				[song release];
			}
		}
    }
    
    artist.songs = songs;    
    
    [xmlDoc release];
    
    return artist;
}

//loads additional images for the artist
-(Artist*) loadImagesForArtist:(Artist*) artist
{
    if (artist == nil) {
        return nil;
    }
    
    int limit = 48;
    
    NSString* surl = [NSString stringWithFormat:
                      @"http://ws.audioscrobbler.com/2.0/?method=artist.getimages&mbid=%@&api_key=%@&limit=%i",
                      artist.artistIdMB, LFM_API_KEY, limit];
    NSURL* url = [NSURL URLWithString:surl];
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return nil;
    }
    
    error = nil;
    DDXMLDocument* xmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        [xmlDoc release];
        return nil;
    }

    DDXMLElement* imgs = [[[xmlDoc rootElement] elementsForName:@"images"] objectAtIndex:0];    
    NSMutableArray* images = [[[NSMutableArray alloc] init] autorelease];        
    
    NSArray* imgElements = [imgs elementsForName:@"image"];
    for (DDXMLElement *imgElement in imgElements) {
        NSString* title = [[[imgElement elementsForName:@"title"] objectAtIndex:0] stringValue];
        
        DDXMLElement* sizes = [[imgElement elementsForName:@"sizes"] objectAtIndex:0];
        DDXMLElement* n = [[sizes nodesForXPath:@"child::size[@name='original']" error:&error] objectAtIndex:0];		
        NSString* urlLarge = [n stringValue];
		NSString* width = [[n attributeForName:@"width"] stringValue];
		NSString* height = [[n attributeForName:@"height"] stringValue];
		CGSize sizeLarge = CGSizeMake([width intValue], [height intValue]);
        
        n = [[sizes nodesForXPath:@"child::size[@name='extralarge']" error:&error] objectAtIndex:0];
        NSString* urlMedium = [n stringValue];
		width = [[n attributeForName:@"width"] stringValue];
		height = [[n attributeForName:@"height"] stringValue];
		CGSize sizeMedium = CGSizeMake([width intValue], [height intValue]);
		
        
        n = [[sizes nodesForXPath:@"child::size[@name='largesquare']" error:&error] objectAtIndex:0];
        NSString* urlSquare = [n stringValue];
		width = [[n attributeForName:@"width"] stringValue];
		height = [[n attributeForName:@"height"] stringValue];
		CGSize sizeSquare = CGSizeMake([width intValue], [height intValue]);
		
        
        ArtistImage* ai = [[ArtistImage alloc] init];
        ai.title = title;
        ai.urlLarge = urlLarge;
        ai.urlMedium = urlMedium;
        ai.urlSmallSquare = urlSquare;
		ai.sizeLarge = sizeLarge;
        ai.sizeMedium = sizeMedium;
		ai.sizeSmallSquare = sizeSquare;
        
        [images addObject:ai];
        [ai release];
    }
    
    artist.images = images;
    [xmlDoc release];
    return artist;
}


//loads similar artists
-(NSArray*) loadArtistsSimilarToArtist:(Artist*) artist
{
    if (artist == nil) {
        return nil;
    }
    
    NSString* surl = [NSString stringWithFormat:
        @"http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&mbid=%@&api_key=%@&limit=%i", 
                      artist.artistIdMB, LFM_API_KEY, SIM_ARTISTS_COUNT];
    NSURL* url = [NSURL URLWithString:surl];
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return nil;
    }
    
    error = nil;
    DDXMLDocument* xmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        [xmlDoc release];
        return nil;
    }
    
    DDXMLElement* sim = [[[xmlDoc rootElement] elementsForName:@"similarartists"] objectAtIndex:0];
    
    NSMutableArray* simArtists = [[[NSMutableArray alloc] init] autorelease];    
    
    NSArray* artistElements = [sim elementsForName:@"artist"];
    for (DDXMLElement *artistElement in artistElements) {
        NSString* aname = [[[artistElement elementsForName:@"name"] objectAtIndex:0] stringValue];
        NSString* mbid = [[[artistElement elementsForName:@"mbid"] objectAtIndex:0] stringValue];
        NSString* aurl = [[[artistElement elementsForName:@"url"] objectAtIndex:0] stringValue];

        NSString* imgUrl = nil;    
        error = nil;
        DDXMLNode* imgNode = [[artistElement nodesForXPath:@"child::image[@size='extralarge']" error:&error] objectAtIndex:0];
        if (error) { NSLog(@"%@",[error localizedDescription]); }
        else {
            imgUrl = [imgNode stringValue];
        }
        
        Artist* art = [[[Artist alloc] init] autorelease];
        art.name = aname;
        art.url = aurl;
        art.artistIdMB = mbid;
        art.imgUrl = imgUrl;
        art.artistId = mbid;
        
        [simArtists addObject:art];
    }
    
    [xmlDoc release];
    
    return simArtists;
}


-(void) loadArtistForName:(NSString*) name
{
    //load data in BG
    [NSThread detachNewThreadSelector:@selector(loadArtistForNameInBG:)
                             toTarget:self 
                           withObject:name];
}

//load artist in BG
-(void) loadArtistForNameInBG:(NSString*) name
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //escape seach name
    NSString *escapedName = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString* surl = [NSString stringWithFormat:
        @"http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=%@&api_key=%@&lang=%@", escapedName, LFM_API_KEY, lang];
    NSURL* url = [NSURL URLWithString:surl];
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];

    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return;
    }
    
    error = nil;
    DDXMLDocument* xmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];

    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        [xmlDoc release];
        return;
    }
    
    DDXMLElement* artistElement = [[[xmlDoc rootElement] elementsForName:@"artist"] objectAtIndex:0];
    NSString* aname = [[[artistElement elementsForName:@"name"] objectAtIndex:0] stringValue];
    NSString* mbid = [[[artistElement elementsForName:@"mbid"] objectAtIndex:0] stringValue];
    NSString* aurl = [[[artistElement elementsForName:@"url"] objectAtIndex:0] stringValue];
    
    DDXMLElement* bio = [[artistElement elementsForName:@"bio"] objectAtIndex:0];
    
    NSString* sum = [[[bio elementsForName:@"summary"] objectAtIndex:0] stringValue];
    NSString* content = [[[bio elementsForName:@"content"] objectAtIndex:0] stringValue];
    
    NSString* imgUrl = nil;    
    error = nil;
    DDXMLNode* imgNode = [[artistElement nodesForXPath:@"child::image[@size='extralarge']" error:&error] objectAtIndex:0];
    if (error) { NSLog(@"%@",[error localizedDescription]); }
    else {
        imgUrl = [imgNode stringValue];
    }
    
    //load tags
    NSMutableArray* tags = [[[NSMutableArray alloc] init] autorelease];
    DDXMLElement* tagsElement = [[artistElement elementsForName:@"tags"] objectAtIndex:0];
    NSArray*  tagElements = [tagsElement elementsForName:@"tag"];
    for (DDXMLElement* te in tagElements) {
        NSString* tag = [[[te elementsForName:@"name"] objectAtIndex:0] stringValue];
        [tags addObject:tag];
    }

    Artist* art = [[[Artist alloc] init] autorelease];
    art.name = aname;
    art.url = aurl;
    art.artistIdMB = mbid;
    art.imgUrl = imgUrl;
    art.bioContent = content;
    art.bioSummary = sum;
    art.artistId = mbid;
    art.tags = tags;
    
    // Post notification that the request is complete
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ArtistLoaded object:art];
    
    [xmlDoc release];

    [pool release];
}

- (UIImage*) loadImageForUrl:(NSString*)surl 
{
    UIImage* img = nil;
    if (surl) {
        NSURL* url = [NSURL URLWithString:surl];
        NSData* data = [NSData dataWithContentsOfURL:url];
        img = [UIImage imageWithData:data];
    }
    return img;
}

@end
