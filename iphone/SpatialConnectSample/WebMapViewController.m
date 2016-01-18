//
//  WebMapViewController.m
//  SpatialConnectSample
//
//  Created by Wes Richardet on 1/14/16.
//  Copyright © 2016 Boundless Spatial. All rights reserved.
//

#import "WebMapViewController.h"

@implementation WebMapViewController

@synthesize lwa, webview, zipFilePath;

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.lwa = [[SCLocalWebApp alloc] initWithWebView:self.webview
                                           delegate:self
                                         andZipFile:self.zipFilePath];
  [self.lwa load];
}

@end
