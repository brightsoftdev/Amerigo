//
//  TopBarViewController.m
//  GridViewTest
//
//  Created by mic on 17.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TopBarViewController.h"
#import "GridViewTestAppDelegate.h"

@implementation TopBarViewController
@synthesize imageView;
@synthesize titleLabel;
@synthesize tagsLabel;
@synthesize playButton;
@synthesize songTitleLabel;
@synthesize songs;
@synthesize segmentedControl;
@synthesize prevNextSegCtrl;



//called when the artist for the top bar is loaded
- (void) artistLoaded:(NSNotification*) notification 
{
    //change artist name in top bar
    Artist* artist = notification.object;
    [self updateArtist:artist];
}

//sets a new image in the top bar
- (void) changeImage:(UIImage*)image 
{
    /* change image animated (fade)*/    
    imageView.image = image;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [imageView.layer addAnimation:transition forKey:nil];
}


- (IBAction)segmentedControlValueChanged:(id)sender {
    GridViewTestAppDelegate* del = (GridViewTestAppDelegate*) [[UIApplication sharedApplication] delegate];
    //index entspricht enum value
    [del changeDetailsView:self.segmentedControl.selectedSegmentIndex];
}


- (IBAction)prevNextSegCtrlValueChanged:(id)sender {
    GridViewTestAppDelegate* del = (GridViewTestAppDelegate*) [[UIApplication sharedApplication] delegate];
    //index entspricht enum value
    if (self.prevNextSegCtrl.selectedSegmentIndex == 0) {
        [del gotoPreviousItem];
    }
    else if (self.prevNextSegCtrl.selectedSegmentIndex == 1) {
        [del gotoNextItem];        
    }
}


- (void) updateArtist:(Artist*) artist {
	//stop playing if needed
	if (streamer) {
		[self stopPlaying];
	}
	
    if (artist == nil) {
        [self changeImage:[UIImage imageNamed:@"noimage.png"]];
        self.titleLabel.text = @"";
        self.tagsLabel.text = @"";
    }
    else {
        self.titleLabel.text = artist.name;
        NSString* s = @"";
        int i=0;
        for (NSString* tag in artist.tags) {
            if (i==0) s = tag;
            else      s = [NSString stringWithFormat:@"%@, %@", s, tag];
            i++;
        }        
        self.tagsLabel.text = s;
		
		//load songs for the artist
		dispatch_async(
		   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			   //do task
			   ArtistDBConnector* con = [[ArtistDBConnector alloc] init];             
			   Artist* a = [con loadSongsForArtist:artist];                   

			   dispatch_async(dispatch_get_main_queue(), ^{
				   //task done
				   [self songsForArtistLoaded:a];
				   [con release];
			   });
		   });
        
        //load image for top controller
        dispatch_async(
           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               //do task
               UIImage* img = [Utilities imageForUrl:artist.imgUrl];               
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   //task done
                   [self changeImage:img];
               });
           });

		
    }
}

-(void) songsForArtistLoaded:(Artist*) artist {
	self.songs = artist.songs;
	songIdx = 0;
	self.songTitleLabel.text = @"";	
	if (self.songs && [self.songs count] > 0) {
		ArtistSong* s = [self.songs objectAtIndex:0];
		self.songTitleLabel.text = s.title;
	}
}

//
// spinButton
//
// Shows the spin button when the audio is loading. This is largely irrelevant
// now that the audio is loaded from a local file.
//
- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [playButton frame];
	playButton.layer.anchorPoint = CGPointMake(0.5, 0.5);
	playButton.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
	
	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	[playButton.layer addAnimation:animation forKey:@"rotationAnimation"];
	
	[CATransaction commit];
}

//
// setButtonImage:
//
// Used to change the image on the playbutton. This method exists for
// the purpose of inter-thread invocation because
// the observeValueForKeyPath:ofObject:change:context: method is invoked
// from secondary threads and UI updates are only permitted on the main thread.
//
// Parameters:
//    image - the image to set on the play button.
//
- (void)setButtonImage:(UIImage *)image
{
	[playButton.layer removeAllAnimations];
	if (!image)	{
		[playButton setImage:[UIImage imageNamed:@"play.png"] forState:0];
	}
	else
	{
		[playButton setImage:image forState:0];
		
		if ([playButton.currentImage isEqual:[UIImage imageNamed:@"refresh.png"]])
		{
			[self spinButton];
		}
	}
}

- (void) startPlaying {
	[self createStreamer];
	[self setButtonImage:[UIImage imageNamed:@"refresh.png"]];
	[streamer start];	
}

- (void) stopPlaying {
	[streamer stop];
	[self destroyStreamer];
	[self setButtonImage:[UIImage imageNamed:@"play.png"]];			
}

-(BOOL) isPlaying {
	return ![playButton.currentImage isEqual:[UIImage imageNamed:@"play.png"]];
}

- (IBAction)playPressed:(id)sender {
	if (songs && [songs count] > 0) {
		BOOL stopped = ![self isPlaying];
		if (stopped)	{
			[self startPlaying];
		}
		else {
			[self stopPlaying];
		}
	}
}

- (IBAction)nextPressed:(id)sender 
{
	if (songs && songIdx+1 < [songs count]) {
		songIdx++;
		ArtistSong* song = [songs objectAtIndex:songIdx];
		self.songTitleLabel.text = song.title;
		BOOL stopped = ![self isPlaying];
		if (!stopped) {
			//stop and play next song
			[self stopPlaying];
			[self startPlaying];			
		}
	}
}

- (IBAction)prevPressed:(id)sender 
{
	if (songs && songIdx > 0) {
		songIdx--;
		ArtistSong* song = [songs objectAtIndex:songIdx];
		self.songTitleLabel.text = song.title;		
		BOOL stopped = ![self isPlaying];
		if (!stopped) {
			//stop and play next song
			[self stopPlaying];
			[self startPlaying];					
		}		
	}	
}

#pragma mark - AudioStreamer

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer
{
	if (streamer) {
		return;
	}
	
	[self destroyStreamer];
	
	ArtistSong* song = [songs objectAtIndex:songIdx];
	NSString* urlString = song.url;
	NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes( nil,(CFStringRef)urlString, NULL, NULL, kCFStringEncodingUTF8) autorelease];
	
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	progressUpdateTimer =
	[NSTimer scheduledTimerWithTimeInterval:0. target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) 
												 name:ASStatusChangedNotification object:streamer];
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		[self setButtonImage:[UIImage imageNamed:@"refresh.png"]];
	}
	else if ([streamer isPlaying])
	{
		[self setButtonImage:[UIImage imageNamed:@"pause.png"]];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		[self setButtonImage:[UIImage imageNamed:@"play.png"]];
	}
	
}

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		//double progress = streamer.progress;
		//NSLog(@"%@", [NSString stringWithFormat:@"Time Played: %.1f seconds", progress]);
	}
	else
	{
		//NSLog(@"Time Played:");
	}
}


#pragma mark -

- (void)dealloc
{
    //remove oberver
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[self destroyStreamer];
	if (progressUpdateTimer)
	{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
	}	
    [imageView release];
    [titleLabel release];
    [tagsLabel release];
    [playButton release];
	[songTitleLabel release];
	[songs dealloc];
    [segmentedControl release];
    [prevNextSegCtrl release];
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
    // Register observer to be notified when artist is loaded
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(artistLoaded:) 
                                                 name:@"ArtistLoaded" object:nil];   
    
    CGRect f = self.view.frame;
    CGRectMake(f.origin.x, f.origin.y, f.size.width, 50);
    self.view.frame = f;
    
    GridViewTestAppDelegate* del = (GridViewTestAppDelegate*) [[UIApplication sharedApplication] delegate];
    [del.splitViewController setSplitPosition:50];
    
}

- (void)viewDidUnload
{	
    [self setImageView:nil];
    [self setTitleLabel:nil];
    [self setTagsLabel:nil];
    [self setSegmentedControl:nil];
    [self setPrevNextSegCtrl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)onBackButtonPressed:(id)sender {
    NSLog(@"goBack");
}


@end
