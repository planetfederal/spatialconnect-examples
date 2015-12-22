//
//  AppDelegate.h
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/19/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <spatialconnect/SpatialConnect.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
  SpatialConnect *sc;
}

@property (strong, nonatomic) UIWindow *window;

- (SpatialConnect*)spatialConnectSharedInstance;

@end

