//
//  SCSwiftJavascriptBridge.m
//  SCExampleApp
//
//  Created by Frank Rowe on 4/21/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(SCJavascript, NSObject)

RCT_EXTERN_METHOD(handler:(NSDictionary *)data)

@end