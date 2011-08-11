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
#import "SearchViewController.h"
#import "ArtistInfoViewController.h"
#import "ArtistInfoImageGridController.h"
#import "ArtistEventsViewController.h"
#import "CHDoublyLinkedList.h"

typedef enum {
    kSearchView = 0,
    kDiscoverView = 1,
    kInfoView = 2,
    kNewsView = 3,
    kImagesView = 4
    } 
DetailsViewType;

@interface GridViewTestAppDelegate : NSObject <UIApplicationDelegate> {
    GridViewController *_gridViewController;
    MGSplitViewController *_splitViewController;
    SearchViewController *_searchViewController;
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
@property (nonatomic, retain) IBOutlet SearchViewController *searchViewController;
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
