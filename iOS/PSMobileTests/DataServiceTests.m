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
#import <SpatialConnect/GeoJSONStore.h>

@interface DataServiceTests : XCTestCase {
  SpatialConnect *sc;
}
- (SCDataStore *)makeDataStore;
@end

@implementation DataServiceTests

- (void)setUp {
  [super setUp];
  [self moveTestBundleToDocsDir];
  sc = [[SpatialConnect alloc] init];
}

- (void)tearDown {
  [super tearDown];
}

- (void)moveTestBundleToDocsDir {
  NSString *path = [[NSBundle bundleForClass:[self class]] resourcePath];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *directoryAndFileNames =
      [fm contentsOfDirectoryAtPath:path error:&error];

  NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  [directoryAndFileNames enumerateObjectsUsingBlock:^(NSString *fileName,
                                                      NSUInteger idx,
                                                      BOOL *stop) {
    if ([fileName containsString:@"scfg"] ||
        [fileName containsString:@"json"] ||
        [fileName containsString:@"geojson"]) {
      NSError *error;
      [fm copyItemAtPath:[NSString stringWithFormat:@"%@/%@", path, fileName]
                  toPath:[NSString
                             stringWithFormat:@"%@/%@", documentsPath, fileName]
                   error:&error];
    }
  }];
}

- (SCDataStore *)makeDataStore {
  NSDictionary *d = @{
    @"type" : @"geojson",
    @"version" : @"1",
    @"uri" : @"feature.geojson",
    @"id" : @"276d2186-24f4-11e5-b345-feff819cdc9f"
  };
  SCStoreConfig *cfg = [[SCStoreConfig alloc] initWithDictionary:d];
  return [[GeoJSONStore alloc] initWithStoreConfig:cfg];
}

- (void)testRegisterStore {
  SCDataStore *dataStore = [self makeDataStore];
  [sc.manager.dataService registerStore:dataStore];
  [sc startAllServices];
  SCDataStore *store =
      [sc.manager.dataService storeByIdentifier:dataStore.storeId];
  XCTAssertNotNil(store, @"Successfully registered store");
}

- (void)testUnregisterStore {
  SCDataStore *dataStore = [self makeDataStore];
  [sc.manager.dataService registerStore:dataStore];
  [sc startAllServices];
  [sc.manager.dataService unregisterStore:dataStore];
  SCDataStore *store =
      [sc.manager.dataService storeByIdentifier:dataStore.storeId];
  XCTAssertNil(store, @"Successfully unregistered store");
}

- (void)testActiveStoreList {
  [sc startAllServices];
  NSArray *stores = [sc.manager.dataService activeStoreList];
  XCTAssertNotNil(stores, @"Active Store List should return the active stores");
  [stores enumerateObjectsUsingBlock:^(SCDataStore *store, NSUInteger idx,
                                       BOOL *stop) {
    XCTAssertTrue(store.status == SC_DATASTORE_RUNNING,
                  "Active Stores should only return Running Stores");
  }];
}

- (void)testStoresByProtocol {
  [sc startAllServices];
  Protocol *p = @protocol(SCSpatialStore);
  NSArray *arr = [sc.manager.dataService storesByProtocol:p];
  [arr enumerateObjectsUsingBlock:^(SCDataStore *store, NSUInteger idx,
                                    BOOL *stop) {
    XCTAssertTrue([store conformsToProtocol:p],
                  "Store should conform to the queried protocol");
  }];
}

- (void)testStoresByProtocolOnlyRunning {
  [sc startAllServices];
  Protocol *p = @protocol(SCSpatialStore);
  NSArray *arr = [sc.manager.dataService storesByProtocol:p onlyRunning:YES];
  [arr enumerateObjectsUsingBlock:^(SCDataStore *store, NSUInteger idx,
                                    BOOL *stop) {
    XCTAssertTrue([store conformsToProtocol:p],
                  "Store should conform to the queried protocol");
    XCTAssertTrue(store.status == SC_DATASTORE_RUNNING,
                  "Store should be running");
  }];
}

- (void)testQueryAllStoresOfProtocol {
  [sc startAllServices];
  Protocol *p = @protocol(SCSpatialStore);
  [[sc.manager.dataService queryAllStoresOfProtocol:p filter:nil]
      subscribeCompleted:^{
        XCTAssertTrue(YES, @"Store queries should be limited by Protocol");
      }];
}

- (void)testQueryAllStores {
  [sc startAllServices];
  [[sc.manager.dataService
      queryAllStores:nil] subscribeNext:^(NSArray *features) {
    XCTAssertNotNil(features, @"Features from each store");
  } error:^(NSError *error) {
    XCTAssertThrows(error);
  } completed:^{
    XCTAssertTrue(YES, @"Query All Stores");
  }];
}

- (void)testQueryStoreById {
  [sc startAllServices];
  NSArray *arr = [sc.manager.dataService activeStoreList];
  XCTAssertTrue(arr.count > 0);
  SCDataStore *ds = arr[0];
  [[sc.manager.dataService queryStoreById:ds.storeId withFilter:nil]
      subscribeNext:^(SCSpatialFeature *feature) {
        XCTAssertNotNil(feature, @"Features from store %@ : %@", ds.name,
                        ds.storeId);
      }
      error:^(NSError *error) {
        XCTAssertThrows(error);
      }
      completed:^{
        XCTAssertTrue(YES, @"Query store by ID");
      }];
}

- (void)testQueryLimit {
  [sc startAllServices];
  SCQueryFilter *filter = [SCQueryFilter new];
  filter.limit = 1;
  [[sc.manager.dataService
      queryAllStores:filter] subscribeNext:^(NSArray *features) {
    XCTAssertTrue(features.count <= filter.limit,
                  @"Features from each store shoudl be %ld",
                  (long)filter.limit);
  } error:^(NSError *error) {
    XCTAssertThrows(error);
  } completed:^{
    XCTAssertTrue(YES, @"Query All Stores");
  }];
}

@end
