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

#import "AppDelegate.h"
#import <SpatialConnect/SpatialConnect.h>
#import <FoldingTabBar/FoldingTabBar.h>
#import <SpatialConnect/GeoJSONStore.h>
#import <SpatialConnect/SCFileUtils.h>
#import "MainViewController.h"

#import "CustomDataStore.h"

@interface AppDelegate ()

@property(nonatomic, retain) UIViewController *mainController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [[UIApplication sharedApplication]
      setStatusBarStyle:UIStatusBarStyleLightContent
               animated:NO];
  [self startSpatialConnect];
  [self setupTabBarLayout];
  return YES;
}

- (void)setupTabBarLayout {
  YALFoldingTabBarController *tabBarController =
      (YALFoldingTabBarController *)self.window.rootViewController;

  YALTabBarItem *mapItem = [[YALTabBarItem alloc]
      initWithItemImage:[UIImage imageNamed:@"store_icon"]
          leftItemImage:nil
         rightItemImage:nil];

  YALTabBarItem *dataItem = [[YALTabBarItem alloc]
      initWithItemImage:[UIImage imageNamed:@"map_icon"]
          leftItemImage:[UIImage imageNamed:@"edit_icon"]
         rightItemImage:[UIImage imageNamed:@"layer_icon"]];

  tabBarController.leftBarItems = @[ mapItem, dataItem ];

  // prepare rightBarItems
  YALTabBarItem *webItem =
      [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"web_icon"]
                                 leftItemImage:nil
                                rightItemImage:nil];

  YALTabBarItem *settingsItem = [[YALTabBarItem alloc]
      initWithItemImage:[UIImage imageNamed:@"settings_icon"]
          leftItemImage:nil
         rightItemImage:nil];

  tabBarController.rightBarItems = @[ webItem, settingsItem ];

  tabBarController.centerButtonImage = [UIImage imageNamed:@"plus_icon"];
  tabBarController.selectedIndex = 3;

  // customize tabBarView
  tabBarController.tabBarView.extraTabBarItemHeight =
      YALExtraTabBarItemsDefaultHeight;
  tabBarController.tabBarView.offsetForExtraTabBarItems =
      YALForExtraTabBarItemsDefaultOffset;
  tabBarController.tabBarView.backgroundColor =
      [UIColor colorWithRed:245.0 / 255.0
                      green:141.0 / 255.0
                       blue:80.0 / 255.0
                      alpha:1];
  tabBarController.tabBarView.tabBarColor = [UIColor colorWithRed:0.0 / 255.0
                                                            green:167.0 / 255.0
                                                             blue:141.0 / 255.0
                                                            alpha:1];
  tabBarController.tabBarViewHeight = YALTabBarViewDefaultHeight;
  tabBarController.tabBarView.tabBarViewEdgeInsets =
      YALTabBarViewHDefaultEdgeInsets;
  tabBarController.tabBarView.tabBarItemsEdgeInsets =
      YALTabBarViewItemsDefaultEdgeInsets;
}

- (void)startSpatialConnect {
  if (!sc) {
    NSString *cfgPath =
        [SCFileUtils filePathFromDocumentsDirectory:@"tests.scfg"];
    sc = [[SpatialConnect alloc] initWithFilepath:cfgPath];
    NSString *filePath =
        [SCFileUtils filePathFromDocumentsDirectory:
                         @"all.geojson"];

    SCStyle *style = [[SCStyle alloc] init];
    style.fillColor = [UIColor orangeColor];
    style.fillOpacity = 0.25f;
    style.strokeColor = [UIColor yellowColor];
    style.strokeOpacity = 0.5f;
    style.strokeWidth = 2;

    GeoJSONStore *geoJSONStore =
        [[GeoJSONStore alloc] initWithResource:filePath withStyle:style];
    geoJSONStore.name = @"LocalStore";
    [sc.manager.dataService registerStore:geoJSONStore];
    CustomDataStore *cds = [[CustomDataStore alloc] init];
    [sc.manager.dataService registerStore:cds];

    [sc startAllServices];
  }
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

- (SpatialConnect *)spatialConnectSharedInstance {
  return sc;
}

@end
