//
//  SCReactBridge.h
//  SCExampleApp
//
//  Created by Frank Rowe on 4/19/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridge.h"

@interface SCReactBridge : NSObject <RCTBridgeModule>

-(SpatialConnect*)sc;

@end
