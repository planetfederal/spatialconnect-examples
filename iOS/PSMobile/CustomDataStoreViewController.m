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

#import "CustomDataStoreViewController.h"
#import "CustomDataStore.h"

@interface CustomDataStoreViewController (PrivateMethods)
- (SpatialConnect*)scShared;
@end

@implementation CustomDataStoreViewController

@synthesize textFieldFilter;
@synthesize textFieldResult;
@synthesize buttonGo;

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (!self) {
    return nil;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  @weakify(self);
  RAC(self.buttonGo, enabled) = [RACSignal combineLatest:@[self.textFieldFilter.rac_textSignal] reduce:^id(NSString *field){
    return @(field.length > 4);
  }];

  [[[[self.buttonGo rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^RACStream *(UIButton *sender) {
    @strongify(self);
    SCQueryFilter *filter = [[SCQueryFilter alloc] init];
//    SCPredicate *pred = [[SCPredicate alloc] initWithValue:@"bacon" andOperator:SCPREDICATE_OPERATOR_EQUAL];
//    pred.value = self.textFieldFilter.text;
//    [filter addPredicate:pred];
    self.textFieldResult.text = @"";
    return [self.scShared.manager.dataService queryStoreById:[CustomDataStore identifier] withFilter:filter];
  }]  deliverOnMainThread] subscribeNext:^(id x) {
    self.textFieldResult.text = [NSString stringWithFormat:@"%@%@%@",self.textFieldResult.text,@"\n\n",x];
  } error:^(NSError *error) {
    NSLog(@"Error: %@",error);
  } completed:^{
    NSLog(@"Fetch Completed");
  }];
}

- (SpatialConnect*)scShared {
  if (!spatialConnect) {
    AppDelegate *ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    spatialConnect = [ad spatialConnectSharedInstance];
  }
  return spatialConnect;
}

@end
