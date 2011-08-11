//
//  BasicPreviewItem.h
//  MusicBrowser
//
//  Created by mic on 22.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface BasicPreviewItem : NSObject <QLPreviewItem>
{
    NSURL * url;
    NSString* title;
}

@property (nonatomic, retain) NSURL*  url;
@property (nonatomic, copy) NSString* title;

@end
