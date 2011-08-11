//
//  BasicPreviewItem.m
//  MusicBrowser
//
//  Created by mic on 22.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BasicPreviewItem.h"


@implementation BasicPreviewItem

@synthesize url, title;

- (NSURL *)previewItemURL {
    return self.url;
}

- (NSString *)previewItemTitle {
    return self.title;
}

-(void)dealloc
{
    self.url = nil;
    self.title = nil;
    [super dealloc];
}

@end
