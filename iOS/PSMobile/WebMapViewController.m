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

#import "WebMapViewController.h"
#import <SpatialConnect/SCDataStore.h>
#import <SpatialConnect/SCGeoJSONExtensions.h>

@interface WebMapViewController ()
@property WebViewJavascriptBridge *bridge;
@property SpatialConnect *spatialConnect;
- (void)parseJSCommand:(id)data;
- (void)setupCommands;
@end

@implementation WebMapViewController

@synthesize webview;

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  if (_bridge) {
    return;
  }

  [self setupCommands];

  AppDelegate *appDel = [[UIApplication sharedApplication] delegate];
  _spatialConnect = [appDel spatialConnectSharedInstance];

  _bridge = [WebViewJavascriptBridge
      bridgeForWebView:self.webview
       webViewDelegate:self
               handler:^(id data, WVJBResponseCallback responseCallback) {
                 [self parseJSCommand:data];
                 responseCallback(@"Response for message from ObjC");
               }];

  [self loadIndexPage];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [self storesList];
}

- (void)loadIndexPage {
  [self.webview
      loadRequest:[NSURLRequest
                      requestWithURL:
                          [NSURL
                              fileURLWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"SpecRunner"
                                                           ofType:@"html"]]]];
  [self.spatialConnect.manager.sensorService enableGPS];
  [self.spatialConnect.manager.sensorService.lastKnown
      subscribeNext:^(CLLocation *loc) {
        CLLocationDistance alt = loc.altitude;
        float lat = loc.coordinate.latitude;
        float lon = loc.coordinate.longitude;
        [_bridge callHandler:@"lastKnownLocation"
                        data:@{
                          @"latitude" : [NSNumber numberWithFloat:lat],
                          @"longitude" : [NSNumber numberWithFloat:lon],
                          @"altitude" : [NSNumber numberWithFloat:alt]
                        }];
      }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)setupCommands {
  commands = [NSMutableDictionary new];
  [commands setObject:[NSValue valueWithPointer:@selector(storesList)]
               forKey:@"stores"];
  [commands setObject:[NSValue valueWithPointer:@selector(spatialQuery:)]
               forKey:@"spatialQuery"];
}

- (void)parseJSCommand:(id)data {
  NSDictionary *command = (NSDictionary *)data;
  if (!command) {
    return;
  }
  NSString *action = command[@"action"];
  id value = command[@"value"];
  SEL sel = [[commands objectForKey:action] pointerValue];
  if (sel) {
    [self performSelector:sel withObject:value];
  }
}

#pragma mark -
#pragma mark JS Commands

- (void)spatialConnectGPS:(id)value {
  BOOL enable = [value boolValue];
  if (enable) {
    [self.spatialConnect.manager.sensorService enableGPS];
  } else {
    [self.spatialConnect.manager.sensorService disableGPS];
  }
}

- (void)storesList {
  NSArray *arr =
      self.spatialConnect.manager.dataService.activeStoreListDictionary;
  [_bridge callHandler:@"storesList" data:@{ @"stores" : arr }];
}

- (void)spatialQuery:(NSString *)identifier {
  if ([identifier isEqualToString:@"allstores"]) {
    [[self.spatialConnect.manager.dataService queryAllStores:nil]
        subscribeNext:^(SCGeometry *g) {
          [_bridge callHandler:@"spatialQuery" data:g.geoJSONDict];
        }];
  } else {
    [[self.spatialConnect.manager.dataService queryStoreById:identifier
                                                  withFilter:nil]
        subscribeNext:^(SCGeometry *g) {
          NSDictionary *gj = g.geoJSONDict;
          NSLog(@"%@", gj);
          [_bridge callHandler:@"spatialQuery" data:gj];
        }];
  }
}

@end
