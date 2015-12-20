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

#import "CustomDataStore.h"

@implementation CustomDataStore

#define STORE_NAME @"CustomDataStore"
#define TYPE @"custom"
#define VERSION 1
#define IDENTIFIER @"1699b31c-3fc3-11e5-a151-feff819cdc9f"

- (id)init {
  self = [super init];
  if (!self) {
    return nil;
  }
  self.status = SC_DATASTORE_STOPPED;
  self.name = STORE_NAME;
  _type = TYPE;
  _version = VERSION;
  _storeId = IDENTIFIER;
  dataUrl = [[NSURL alloc] initWithString:@"https://baconipsum.com/api/"
                           @"?type=all-meat&paras=5&start-with-"
                           @"lorem=1&format=json"];
  return self;
}

- (RACSignal *)query:(SCQueryFilter *)filter {
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:dataUrl];
  return [[[[NSURLConnection
      rac_sendAsynchronousRequest:request] map:^id(RACTuple *value) {
    NSData *data = value.second;
    NSError *error = nil;
    NSArray *array =
        [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    return array;
  }] flattenMap:^RACStream *(NSArray *array) {
    return array.rac_sequence.signal;
  }] filter:^BOOL(NSString *str) {
    NSLog(@"%@", str);
    if ([filter testValue:str]) {
      return YES;
    } else {
      return NO;
    }
  }];
}

- (RACSignal *)createFeature:(SCSpatialFeature *)feature {
  return nil;
}

- (RACSignal *)updateFeature:(SCSpatialFeature *)feature {
  return nil;
}

- (RACSignal *)deleteFeature:(SCSpatialFeature *)feature {
  return nil;
}

- (void)start {
  self.status = SC_DATASTORE_STARTED;
}

- (void)stop {
  self.status = SC_DATASTORE_STOPPED;
}

- (void)pause {
}

- (void)resume {
}

+ (NSString *)identifier {
  return IDENTIFIER;
}

@end
