/*****************************************************************************
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 ******************************************************************************/

#import "TestViewController.h"
#import <SpatialConnect/SCJavascriptBridge.h>
#import <SpatialConnect/SCJavascriptCommands.h>

@interface TestViewController ()
@property SCJavascriptBridge *bridge;
@property SpatialConnect *spatialConnect;
@end

@implementation TestViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  if (_bridge) {
    return;
  }
  AppDelegate *appDel = [[UIApplication sharedApplication] delegate];
  _spatialConnect = [appDel spatialConnectSharedInstance];
  _bridge = [[SCJavascriptBridge alloc] initWithWebView:self.webview
                                               delegate:self
                                                     sc:_spatialConnect];

  [self loadIndexPage];
}

- (void)loadIndexPage {
  NSString *pageURL =
      [[NSBundle mainBundle] pathForResource:@"SpecRunner" ofType:@"html"];
  [_webview loadRequest:[NSURLRequest
                            requestWithURL:[NSURL fileURLWithPath:pageURL]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
  NSLog(@"Started");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  NSLog(@"Finished");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  NSLog(@"%@", error);
}

@end
