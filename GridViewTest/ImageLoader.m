//
//  ImageLoader.m
//  GridViewTest
//
//  Created by mic on 16.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageLoader.h"


@implementation ImageLoader

@synthesize imgUrl, idString, delegate;

//void (^block) (UIImage*);

-(void) start 
{
    if (imgUrl) {
        NSURL* url = [NSURL URLWithString:imgUrl];
        
        if (url) {	
            NSURLRequest* request = [NSURLRequest requestWithURL:url 
                                                     cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                 timeoutInterval:20.0];
            
            connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
        }
    }
}

//- (void)startWithBlock:(void (^)(UIImage*))aBlock {
//    block = aBlock;
//    [self start];
//}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Response: %@", response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
}

//the URL connection calls this repeatedly as data arrives
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
	
    UIImage* img = [UIImage imageWithData:data];
    
	[data release]; //don't need this any more, its in the UIImage now
	data = nil;
    
    if (delegate) {
        [delegate imageLoaded:img forIdString:idString];
    }

//    if (block) {
//        block(img);
//    }
}



- (void)dealloc {
    [idString release];
    [imgUrl release];
	[connection cancel]; //in case the URL is still downloading
	[connection release];
	[data release];     
    [super dealloc];
}

@end
