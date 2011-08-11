//
//  ImagePreviewController.h
//  MusicBrowser
//
//  Created by mic on 22.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtistDBConnector.h"
#import "ArtistImage.h"
#import "Utilities.h"

@interface ImagePreviewController : UIViewController {
	UIImageView* imageView;
}

- (void) showImage:(ArtistImage*)artistImage;

@end
