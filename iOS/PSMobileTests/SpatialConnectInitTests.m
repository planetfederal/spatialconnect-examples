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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <SpatialConnect/SpatialConnect.h>

@interface PSMobileTests : XCTestCase

@end

@implementation PSMobileTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSpatialConnectDataSweep {
  SpatialConnect *sc = [[SpatialConnect alloc] init];
  [sc startAllServices];
  NSArray *stores = [sc.manager.dataService activeStoreList];
  XCTAssertGreaterThan(stores.count, 0,"Stores started successfully");
  [[sc.manager.dataService queryAllStores:nil] subscribeNext:^(NSArray *featureArray) {
    XCTAssertGreaterThan(featureArray.count, 0,"Stores Queried Successfully");
  } error:^(NSError *error) {
    XCTFail(@"%@",[error description]);
  } completed:^{
    
  }];
}

- (void)testSpatialConnectConfigFile {
  NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ps" ofType:@"scfg"];
  SpatialConnect *sc = [[SpatialConnect alloc] initWithFilepath:filePath];
  [sc startAllServices];
  NSArray *stores = [sc.manager.dataService activeStoreList];
  XCTAssertGreaterThan(stores.count, 0,"Stores started successfully");
  [[sc.manager.dataService queryAllStores:nil] subscribeNext:^(NSArray *featureArray) {
    XCTAssertGreaterThan(featureArray.count, 0,"Stores Queried Successfully");
  } error:^(NSError *error) {
    XCTFail(@"%@",[error description]);
  } completed:^{
    
  }];
}

- (void)testSpatialConnectConfigFileArray {
  NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ps" ofType:@"scfg"];
  NSString *filePath2 = [[NSBundle bundleForClass:[self class]] pathForResource:@"ps2" ofType:@"scfg"];
  SpatialConnect *sc = [[SpatialConnect alloc] initWithFilepaths:@[filePath,filePath2]];
  [sc startAllServices];
  NSArray *stores = [sc.manager.dataService activeStoreList];
  XCTAssertGreaterThan(stores.count, 0,"Stores started successfully");
  [[sc.manager.dataService queryAllStores:nil] subscribeNext:^(NSArray *featureArray) {
    XCTAssertGreaterThan(featureArray.count, 0,"Stores Queried Successfully");
  } error:^(NSError *error) {
    XCTFail(@"%@",[error description]);
  } completed:^{
    
  }];
}

@end
