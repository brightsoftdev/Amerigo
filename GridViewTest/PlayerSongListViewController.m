//
//  PlayerSongListViewController.m
//  Amerigo
//
//  Created by mic on 23.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerSongListViewController.h"



@implementation PlayerSongListViewController

@synthesize songs;


- (void)dealloc
{
    [self.songs release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    self.contentSizeForViewInPopover = CGSizeMake(300, 600);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.songs) {
        return [self.songs count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    if (self.songs) {
        ArtistSong* song = [self.songs objectAtIndex:indexPath.row];
        cell.textLabel.text = song.title;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (songs) {
        ArtistSong* song =[self.songs objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"songSelected" object:song];        
    }
}

@end
