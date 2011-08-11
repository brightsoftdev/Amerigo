//
//  GridViewTestAppDelegate.m
//  GridViewTest
//
//  Created by mic on 15.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GridViewTestAppDelegate.h"
#import "SearchViewController.h"
#import "ImageBackgroundViewController.h"
#include "TargetConditionals.h"

@implementation GridViewTestAppDelegate
@synthesize gridViewController = _gridViewController;

@synthesize window=_window;
@synthesize navigationController=_navigationController;
@synthesize splitViewController = _splitViewController;
@synthesize searchViewController = _searchViewController;
@synthesize artistInfoController, imagesController;
@synthesize eventsController;


@synthesize searchHistory;

UIViewController* gridDummyCtl;
UIViewController* imagesDummyCtl;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.splitViewController.vertical = NO;
    self.splitViewController.showsMasterInPortrait = TRUE;
    
    self.splitViewController.splitWidth = 0;

    //create the artist info controller
    self.artistInfoController = [[ArtistInfoViewController alloc] initWithNibName:@"ArtistInfoView" bundle:nil]; 

    //create gridview controller (similar artist)
    ImageBackgroundViewController* bgc = [[ImageBackgroundViewController alloc] initWithNibName:@"ImageBackgroundView" bundle:nil];    
    gridDummyCtl = [[UIViewController alloc] init];
    gridDummyCtl.view.frame = self.gridViewController.view.frame;
    [gridDummyCtl.view addSubview:bgc.view];
    [gridDummyCtl.view addSubview:self.gridViewController.gridView];    
    [bgc release];
    
    //create the images controller
    self.imagesController = [[ArtistInfoImageGridController alloc] init];
    ImageBackgroundViewController* bgc2 = [[ImageBackgroundViewController alloc] initWithNibName:@"ImageBackgroundView" bundle:nil];    
    imagesDummyCtl = [[UIViewController alloc] init];
    imagesDummyCtl.view.frame = self.imagesController.view.frame;
    [imagesDummyCtl.view addSubview:bgc2.view];
    [imagesDummyCtl.view addSubview:self.imagesController.gridView];    
    [bgc2 release];
    
    //create events controller
    self.eventsController = [[ArtistEventsViewController alloc] initWithNibName:@"ArtistEventsView" bundle:nil];
    currentHistoryItemIdx = 0;
    
    //create search history list
    self.searchHistory = [[CHDoublyLinkedList alloc] init];

    [self.window addSubview:self.splitViewController.view];
    [self.window makeKeyAndVisible];
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    //get all artists on the device
    libraryArtists = [[NSMutableArray alloc] init];
    for (MPMediaItemCollection *collection in [[MPMediaQuery artistsQuery] collections]) {
        NSString* name = [[collection representativeItem] valueForProperty:MPMediaItemPropertyArtist];
        [libraryArtists addObject:name];
    }

    if ([libraryArtists count] > 0) {
        int r = arc4random() % [libraryArtists count]+1;
        NSString* searchFor = [libraryArtists objectAtIndex:r];
        [self performSearch:searchFor];
    }
    //TODO What to search for if library is empty?
#endif

    
#if (TARGET_IPHONE_SIMULATOR)
    //on simulator just search for static artist
    [self performSearch:@"Nirvana"];
#endif
    
    return YES;
}


//called when the details view selection changes
- (void) changeDetailsView:(DetailsViewType) viewType 
{
    //TODO hide keyboard if it's visible
    UIViewController* ctl = nil;
    switch (viewType) {
        case kSearchView:
            ctl = self.searchViewController;
            [imagesController viewWillDisappear:true];
            break;
        case kDiscoverView:           
            ctl = gridDummyCtl;
            [imagesController viewWillDisappear:true];
            break;
        case kInfoView:
            ctl = self.artistInfoController;
            [imagesController viewWillDisappear:true];
            break;
        case kNewsView:
            ctl = self.eventsController;
            [imagesController viewWillDisappear:true];
            break;
        case kImagesView:
            //we need to inform the real view controller that the view will be displayed 
            //this is not done automatically becaus we uses the ImageBackgrounViewController 
            [imagesController viewWillAppear:true];
            imagesController.view.hidden = false;
            ctl = imagesDummyCtl;
            break;    
    }
    
    if (ctl) {
        /* switch to the other view animated using CATransition */
        CATransition *applicationLoadViewIn = [CATransition animation];
        [applicationLoadViewIn setDuration:0.4];
        [applicationLoadViewIn setType:kCATransitionFade];
        [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [[self.splitViewController.view layer] addAnimation:applicationLoadViewIn forKey:kCATransitionFade];
        
        //set the new details view controller
        [self.splitViewController setDetailViewController:ctl];
        //we need to refresh subviews manually
        [self.splitViewController layoutSubviewsWithAnimation:NO];
    }
}


- (void)gotoPreviousItem 
{
    //if history count > 1 and current item is not the first element of the history 
    if ([self.searchHistory count] > 1 && currentHistoryItemIdx > 0) 
    {
        //get predecessor of current item
        NSString* prev = [self.searchHistory objectAtIndex:currentHistoryItemIdx-1];
        //NSString* current = [self.searchHistory objectAtIndex:currentHistoryItemIdx];
        //set current index to previous item
        currentHistoryItemIdx--;
        
        //now search for prev item
        [self searchFor:prev];

    }

}

- (void)gotoNextItem 
{
    //if history count > 1 and the current item is not the last one
    if ([self.searchHistory count] > 1 && currentHistoryItemIdx < [self.searchHistory count] -1)
    {
        //get successor of the current elemnt
        NSString* next = [self.searchHistory objectAtIndex:currentHistoryItemIdx+1];
        //NSString* current = [self.searchHistory objectAtIndex:currentHistoryItemIdx];
        
        //set current index to next item
        currentHistoryItemIdx++;
        
        //now search for next item
        [self searchFor:next];
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [self.searchHistory release];
    [eventsController release];
    [libraryArtists release];
    [gridDummyCtl release];
    [imagesDummyCtl release];
    [imagesController release];
    [_window release];
    [_navigationController release];
    [_gridViewController release];
    [_splitViewController release];
    [_searchViewController release];
    [artistInfoController release];
    [super dealloc];
}


//called when searching for an artist (manually or thru in-app navigation)
//does not add search history entry
-(void) searchFor:(NSString*)searchTerm {     
    //start loading new artist data
    ArtistDBConnector* con = [[[ArtistDBConnector alloc] init] autorelease];
    [con loadArtistForName:searchTerm];
}


//searches for a entered artist name
//and adds an entry to the search history
- (void) performSearch:(NSString*) searchTerm {
    
    if (searchTerm == nil) {
        return; //do nothing if search string is nil
    }
    
    //if the current item is not the last one
    if (currentHistoryItemIdx < [self.searchHistory count]-1) {
        //remove all entries after the currrent item
        for (int idx = [self.searchHistory count]-1; idx > currentHistoryItemIdx; idx--) {
            [self.searchHistory removeObjectAtIndex:idx];
        }
    }
    
    //add entry to search history (at the end)
    [self.searchHistory addObject:searchTerm];
    //update index of current history item
    currentHistoryItemIdx = [self.searchHistory count]-1;
    
    //perform the search operation
    [self searchFor:searchTerm];
}

@end