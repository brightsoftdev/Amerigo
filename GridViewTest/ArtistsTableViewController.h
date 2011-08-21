//
//  ArtistsTableViewController.h
//  Amerigo
//
//  Created by Michael Anteboth on 21.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ArtistsTableViewController : UITableViewController {
	NSMutableArray* data;
	UIPopoverController* popoverController;
}

@property (nonatomic, retain) UIPopoverController* popoverController;

@end
