//
//  ArtistImage.h
//  MusicBrowser
//
//  Created by mic on 20.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ArtistImage : NSObject<NSCopying> {
    NSString* title;
    NSString* urlLarge;
	CGSize sizeLarge;
    NSString* urlMedium;
	CGSize sizeMedium;;	
    NSString* urlSmallSquare;
	CGSize sizeSmallSquare;	
    int index;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* urlLarge;
@property (nonatomic, retain) NSString* urlMedium;
@property (nonatomic, retain) NSString* urlSmallSquare;
@property int index;
@property CGSize sizeLarge;
@property CGSize sizeMedium;;	
@property CGSize sizeSmallSquare;	


@end
