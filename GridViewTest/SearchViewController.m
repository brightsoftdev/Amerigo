//
//  SearchViewController.m
//  GridViewTest
//
//  Created by mic on 16.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "GridViewTestAppDelegate.h"
#import "ArtistsTableViewController.h"

@implementation SearchViewController

@synthesize artistTextField, popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [artistTextField release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setArtistTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

//starts the search operation
- (IBAction)onDonePressed:(id)sender 
{
    [self.artistTextField resignFirstResponder];
    GridViewTestAppDelegate* delegate = (GridViewTestAppDelegate*) [[UIApplication sharedApplication] delegate];
    [delegate performSearch:self.artistTextField.text];
}

//pressed when the list of artists should be shown
- (IBAction)onListArtistsButtonPressed:(id)sender 
{
	//create the details view controller of the popover controller
	//the artitsts list view
	ArtistsTableViewController* content = [[ArtistsTableViewController alloc] initWithNibName:@"ArtistsTableView" bundle:nil];
	
	//create the popover controller
	UIPopoverController* aPopover = [[UIPopoverController alloc] initWithContentViewController:content];	

	// Store the popover in a custom property for later use.
	self.popoverController = aPopover;
	//set popovercontroller in details view
	content.popoverController = aPopover;

	//release controllers
	[aPopover release];
	[content release];
	
	//present popover controller left beside the button
	CGRect frame = ((UIButton*) sender).frame;
	[self.popoverController presentPopoverFromRect:frame 
											inView:self.view 
								   permittedArrowDirections:UIPopoverArrowDirectionLeft 
										  animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self.artistTextField resignFirstResponder];
    [self onDonePressed:nil];
    return YES;
}

@end
