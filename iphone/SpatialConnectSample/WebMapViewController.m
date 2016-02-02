//
//  WebMapViewController.m
//  SpatialConnectSample
//
//  Created by Wes Richardet on 1/14/16.
//  Copyright © 2016 Boundless Spatial. All rights reserved.
//

#import "AppDelegate.h"
#import "WebMapViewController.h"

@implementation WebMapViewController

@synthesize lwa, webview, zipFilePath;

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  AppDelegate *del = [[UIApplication sharedApplication] delegate];

  self.lwa =
      [[SCLocalWebApp alloc] initWithWebView:self.webview
                                    delegate:self
                              spatialConnect:[del spatialConnectSharedInstance]
                                  andZipFile:self.zipFilePath];
  [self.lwa load];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.webview.scalesPageToFit = NO;
}

@end
