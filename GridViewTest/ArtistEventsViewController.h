//
//  ArtistEventsViewController.h
//  MusicBrowser
//
//  Created by mic on 27.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Artist.h"
#import "ArtistEvent.h"
#import "ArtistDBConnector.h"


@interface ArtistEventsViewController : UIViewController<UIWebViewDelegate> {
    
    UIWebView* webView;
    UIWebView *newsWebView;
}
@property (nonatomic, retain) IBOutlet UIWebView* webView;
@property (nonatomic, retain) IBOutlet UIWebView *newsWebView;


- (void) artistEventsLoaded:(Artist*)a;


@end
