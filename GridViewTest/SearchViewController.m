//
//  SearchViewController.m
//  GridViewTest
//
//  Created by mic on 16.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "GridViewTestAppDelegate.h"

@implementation SearchViewController
@synthesize artistTextField;

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

- (IBAction)onCancelPressed:(id)sender {
}

- (IBAction)onDonePressed:(id)sender {
    [self.artistTextField resignFirstResponder];
    GridViewTestAppDelegate* delegate = (GridViewTestAppDelegate*) [[UIApplication sharedApplication] delegate];
    [delegate performSearch:self.artistTextField.text];
}


-(BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self.artistTextField resignFirstResponder];
    [self onDonePressed:nil];
    return YES;
}

@end
