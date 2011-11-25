//
//  AppInfoView.m
//  Amerigo
//
//  Created by mic on 05.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppInfoView.h"


@implementation AppInfoView
@synthesize copyrightLabel;
@synthesize appVersionLabel;
@synthesize licenseTextView;

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
    [copyrightLabel release];
    [appVersionLabel release];
    [licenseTextView release];
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
    
    self.contentSizeForViewInPopover = CGSizeMake(400, 500);
}

- (void)viewDidUnload
{
    [self setCopyrightLabel:nil];
    [self setAppVersionLabel:nil];
    [self setLicenseTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
