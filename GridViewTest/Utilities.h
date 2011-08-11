//
//  Utilities.h
//  MusicBrowser
//
//  Created by Michael Anteboth on 23.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface Utilities : NSObject {
	
}

// Methods
- (UIImage *) roundCorners: (UIImage*) img;

+ (void) setNewImageOfImageView:(UIImageView*) imgView newImage:(UIImage*) img ;

+(UIImage*) imageForUrl:(NSString*) urlString;

@end