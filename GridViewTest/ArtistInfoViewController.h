//
//  ArtistInfoViewController.h
//  GridViewTest
//
//  Created by mic on 18.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Artist.h"
#import "ArtistInfoImageGridController.h"
#import "ArtistDBConnector.h"

@interface ArtistInfoViewController : UIViewController {
    
    UIWebView *biographyWebView;
    ArtistInfoImageGridController *imageGridViewController;
    Artist* selectedArtist;
}

@property (nonatomic, retain) IBOutlet UIWebView *biographyWebView;
@property (nonatomic, retain) IBOutlet ArtistInfoImageGridController *imageGridViewController;


@end
