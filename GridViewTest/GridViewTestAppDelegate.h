//
//  GridViewTestAppDelegate.h
//  GridViewTest
//
//  Created by mic on 15.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GridViewController.h"
#import "MGSplitViewController.h"
#import "ArtistInfoViewController.h"
#import "ArtistInfoImageGridController.h"
#import "ArtistEventsViewController.h"
#import "CHDoublyLinkedList.h"

typedef enum {
    kDiscoverView = 0,
    kInfoView = 1,
    kNewsView = 2,
    kImagesView = 3
    } 
DetailsViewType;

@interface GridViewTestAppDelegate : NSObject <UIApplicationDelegate> {
    GridViewController *_gridViewController;
    MGSplitViewController *_splitViewController;
    ArtistInfoViewController* artistInfoController;
    ArtistInfoImageGridController* imagesController;
    ArtistEventsViewController* eventsController;
    NSMutableArray* libraryArtists;
    CHDoublyLinkedList* searchHistory;
    int currentHistoryItemIdx;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet GridViewController *gridViewController;

@property (nonatomic, retain) IBOutlet MGSplitViewController *splitViewController;
@property (nonatomic, retain) ArtistInfoViewController* artistInfoController;
@property (nonatomic, retain) ArtistInfoImageGridController* imagesController;
@property (nonatomic, retain) ArtistEventsViewController* eventsController;

@property (nonatomic, retain) CHDoublyLinkedList* searchHistory;

- (void) performSearch:(NSString*) searchTerm;
- (void) changeDetailsView:(DetailsViewType) viewType;
- (void) searchFor:(NSString*)searchTerm;

- (void) gotoPreviousItem;
- (void) gotoNextItem;

@end
