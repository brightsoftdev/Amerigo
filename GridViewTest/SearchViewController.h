//
//  SearchViewController.h
//  GridViewTest
//
//  Created by mic on 16.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchViewController : UIViewController {
    
    UITextField *artistTextField;
}
- (IBAction)onCancelPressed:(id)sender;
- (IBAction)onDonePressed:(id)sender;
@property (nonatomic, retain) IBOutlet UITextField *artistTextField;

@end
