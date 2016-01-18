//
//  WebMapViewController.h
//  SpatialConnectSample
//
//  Created by Wes Richardet on 1/14/16.
//  Copyright © 2016 Boundless Spatial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <spatialconnect/SCLocalWebApp.h>

@interface WebMapViewController : UIViewController <UIWebViewDelegate>

@property(strong, nonatomic) SCLocalWebApp *lwa;
@property(weak, nonatomic) IBOutlet UIWebView *webview;
@property(strong, nonatomic) NSString *zipFilePath;

@end
