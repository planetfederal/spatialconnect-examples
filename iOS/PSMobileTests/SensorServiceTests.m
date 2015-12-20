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

#import <XCTest/XCTest.h>
#import <SpatialConnect/SpatialConnect.h>
#import <SpatialConnect/SCPoint.h>

@interface SensorServiceTests : XCTestCase {
  SpatialConnect *sc;
}

@end

@implementation SensorServiceTests

- (void)setUp {
  [super setUp];
  sc = [[SpatialConnect alloc] init];
  [sc startAllServices];
}

- (void)tearDown {
  [super tearDown];
  [sc stopAllServices];
  sc = nil;
}

- (void)testGPSDisable {
  [sc.manager.sensorService enableGPS];
  [sc.manager.sensorService disableGPS];
  [[sc.manager.sensorService lastKnown] subscribeNext:^(id x) {
    XCTFail(@"GPS Still reporting points but should have been disabled");
  } error:^(NSError *error) {
    XCTFail(@"%@",error.description);
  }];
}

- (void)testGPSEnableAndUpdatesLocation {
  [sc.manager.sensorService disableGPS];
  [sc.manager.sensorService enableGPS];
  __block SCPoint *lastKnownPoint;
  __block int count = 0;
  [[sc.manager.sensorService lastKnown] subscribeNext:^(SCPoint *p) {
    if ([lastKnownPoint isEqual:p]) {
      XCTFail(@"GPS Reporting but not updating");
    } else {
      lastKnownPoint = p;
      count++;
    }
    if (count > 5) {
      XCTAssertTrue(YES,@"GPS Sent 5 new data locations");
    }
  } error:^(NSError *error) {
    XCTFail(@"%@",error.description);
  }];
}


@end
