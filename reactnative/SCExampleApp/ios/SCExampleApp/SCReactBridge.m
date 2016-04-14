//
//  SCReactBridge.m
//  SCExampleApp
//
//  Created by Frank Rowe on 4/19/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "AppDelegate.h"
#import "SCReactBridge.h"
#import "RCTLog.h"
#import "RCTEventDispatcher.h"

@implementation SCReactBridge

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

-(id)init {
  self = [super init];
  if (!self) return nil;
  [self startSensorService];
  return self;
}

- (SpatialConnect*)sc {
  AppDelegate *del = [[UIApplication sharedApplication] delegate];
  return [del spatialConnectSharedInstance];
}

- (void)startSensorService {
  [self.sc.manager.sensorService enableGPS];
  [self.sc.manager.sensorService.lastKnown
   subscribeNext:^(CLLocation *loc) {
     float lat = loc.coordinate.latitude;
     float lon = loc.coordinate.longitude;
     [self lastKnownReceived:@{@"lat": @(lat), @"lon": @(lon)}];
   }];
}

- (void)lastKnownReceived:(NSDictionary *)location
{
  [self.bridge.eventDispatcher sendAppEventWithName:@"lastKnown" body:location];
}

@end
