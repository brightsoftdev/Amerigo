//
//  MainViewController.h
//  GridViewTest
//
//  Created by mic on 18.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridViewController.h"
#import "TopBarViewController.h"


@interface MainViewController : UIViewController {
    
    TopBarViewController *topViewController;
    GridViewController *gridViewController;
}
@property (nonatomic, retain) IBOutlet GridViewController *gridViewController;
@property (nonatomic, retain) IBOutlet TopBarViewController *topViewController;

@end
