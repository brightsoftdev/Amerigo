//
//  ArtistsTableViewController.m
//  Amerigo
//
//  Created by Michael Anteboth on 21.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArtistsTableViewController.h"
#import "GridViewTestAppDelegate.h"

@implementation ArtistsTableViewController

@synthesize popoverController;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

	data = [[NSMutableArray alloc] init];
	
    self.clearsSelectionOnViewWillAppear = YES;
	
	self.contentSizeForViewInPopover = CGSizeMake(300, 400);
	
#if !(TARGET_IPHONE_SIMULATOR)
    //get all artists on the device
    for (MPMediaItemCollection *collection in [[MPMediaQuery artistsQuery] collections]) {
        NSString* name = [[collection representativeItem] valueForProperty:MPMediaItemPropertyArtist];
        [data addObject:name];
    }
#endif
	
    
#if (TARGET_IPHONE_SIMULATOR)
    //on simulator just add some static items
    [data addObject:@"Nirvana"];
    [data addObject:@"Metallica"];
    [data addObject:@"Megadeth"];
    [data addObject:@"R.E.M."];
    [data addObject:@"Aerosmith"];
    [data addObject:@"Pearl Jam"];
    [data addObject:@"The Rolling Stones"];
    [data addObject:@"The Beatles"];
    [data addObject:@"The Doors"];
    [data addObject:@"Led Zeppelin"];	
    [data addObject:@"Deep Purple"];	
#endif
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	
	//we need to release the data array
	[data release];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [data count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
	cell.textLabel.text = [data objectAtIndex:indexPath.row];

    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return @"Künstler aus Mediathek";
	} else {
		return @"";
	}
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	GridViewTestAppDelegate* del = (GridViewTestAppDelegate*) [[UIApplication sharedApplication] delegate];
	//on row selection 
	//search for selected artist
	NSString* artist = [data objectAtIndex:indexPath.row];
	[del performSearch:artist];
	
	//and close the view
	[self.popoverController dismissPopoverAnimated:TRUE];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[popoverController release];
    [super dealloc];
}


@end

