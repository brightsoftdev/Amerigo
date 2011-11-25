//
//  AppInfoView.h
//  Amerigo
//
//  Created by mic on 05.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppInfoView : UIViewController {

    UILabel *copyrightLabel;
    UILabel *appVersionLabel;
    UITextView *licenseTextView;
}
@property (nonatomic, retain) IBOutlet UILabel *copyrightLabel;
@property (nonatomic, retain) IBOutlet UILabel *appVersionLabel;
@property (nonatomic, retain) IBOutlet UITextView *licenseTextView;

@end
