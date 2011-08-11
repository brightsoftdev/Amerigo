//
//  ImageLoader.h
//  GridViewTest
//
//  Created by mic on 16.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageLoaderDelegate <NSObject>

-(void) imageLoaded:(UIImage*) img forIdString:(NSString*) idString;

@end

@interface ImageLoader : NSObject {
    NSString* imgUrl;
    NSString* idString;
    id<ImageLoaderDelegate> delegate;
    
    NSURLConnection* connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData* data; //keep reference to the data so we can collect it as it downloads
}

@property (nonatomic, retain) NSString* imgUrl;
@property (nonatomic, retain) NSString* idString;
@property (nonatomic, retain) id<ImageLoaderDelegate> delegate;

-(void) start;


//- (void)startWithBlock:(void (^)(UIImage*))aBlock;

@end
