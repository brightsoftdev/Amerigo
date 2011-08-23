//
//  PlayerSongListViewController.h
//  Amerigo
//
//  Created by mic on 23.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtistSong.h"


@interface PlayerSongListViewController : UITableViewController {
    NSArray* songs;
}

@property (nonatomic, retain) NSArray* songs;

@end
