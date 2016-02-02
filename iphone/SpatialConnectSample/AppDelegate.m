//
//  AppDelegate.m
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/19/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import "AppDelegate.h"
#import <spatialconnect/SpatialConnect.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  [self startSpatialConnect];

  return YES;
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

- (void)startSpatialConnect {
  if (!sc) {
    NSString *cfgPath = [SCFileUtils filePathFromMainBundle:@"tests.scfg"];
    //    [SCFileUtils filePathFromDocumentsDirectory:@"tests.scfg"];
    sc = [[SpatialConnect alloc] initWithFilepath:cfgPath];
    NSURL *URL = [NSURL URLWithString:@"https://portal.opengeospatial.org"];

    [NSURLRequest
            .class performSelector:NSSelectorFromString(
                                       @"setAllowsAnyHTTPSCertificate:forHost:")
                        withObject:NSNull.null // Just need to pass non-nil here
                        // to appear as a BOOL YES, using
                        // the NSNull.null singleton is
                        // pretty safe
                        withObject:[URL host]];
    NSURL *URL2 = [NSURL URLWithString:@"https://s3-us-west-2.amazonaws.com"];

    [NSURLRequest
            .class performSelector:NSSelectorFromString(
                                       @"setAllowsAnyHTTPSCertificate:forHost:")
                        withObject:NSNull.null // Just need to pass non-nil here
                        // to appear as a BOOL YES, using
                        // the NSNull.null singleton is
                        // pretty safe
                        withObject:[URL2 host]];
    NSURL *URL3 = [NSURL URLWithString:@"https://s3.amazonaws.com"];

    [NSURLRequest
            .class performSelector:NSSelectorFromString(
                                       @"setAllowsAnyHTTPSCertificate:forHost:")
                        withObject:NSNull.null // Just need to pass non-nil here
                        // to appear as a BOOL YES, using
                        // the NSNull.null singleton is
                        // pretty safe
                        withObject:[URL3 host]];

    SCStyle *style = [[SCStyle alloc] init];
    style.fillColor = [UIColor orangeColor];
    style.fillOpacity = 0.25f;
    style.strokeColor = [UIColor yellowColor];
    style.strokeOpacity = 0.5f;
    style.strokeWidth = 2;

    [sc startAllServices];
  }
}

- (SpatialConnect *)spatialConnectSharedInstance {
  return sc;
}

@end
