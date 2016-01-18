//
//  WebDownloadViewController.h
//  SpatialConnectSample
//
//  Created by Wes Richardet on 1/13/16.
//  Copyright © 2016 Boundless Spatial. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebDownloadViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textFieldWeb;
- (IBAction)buttonPressDownload:(id)sender;

@end
