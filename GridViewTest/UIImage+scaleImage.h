//
//  UIImage+scaleImage.h
//  Amerigo
//
//  Created by Anteboth Michael on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (scaleImage)
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
@end;
