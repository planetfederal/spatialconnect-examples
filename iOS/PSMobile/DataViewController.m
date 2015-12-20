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


#import "DataViewController.h"
#import "DataStoreDetailViewController.h"

@interface DataViewController ()
-(SpatialConnect*)scShared;
@end

@implementation DataViewController

@synthesize dataTableView;

-(SpatialConnect*)scShared {
  if (!spatialConnect) {
    AppDelegate *ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    spatialConnect = [ad spatialConnectSharedInstance];
  }
  return spatialConnect;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  stores = self.scShared.manager.dataService.activeStoreListDictionary;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma makr UITableViewDelegate Methods

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DataManagerCell"];
  
  UILabel *storeIdLabel = (UILabel*)[cell viewWithTag:100];
  UILabel *storeTypeLabel = (UILabel*)[cell viewWithTag:101];
  
  NSDictionary *storeDict = stores[indexPath.row];
  NSString *storeId = (NSString*)[storeDict objectForKey:@"storeid"];
  NSString *name = (NSString*)[storeDict objectForKey:@"name"];
  storeIdLabel.text = storeId; //;
  storeTypeLabel.text = name; //
  
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return stores.count;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  DataStoreDetailViewController *vc = segue.destinationViewController;
  vc.dataStoreDetail = [stores objectAtIndex:[[self.dataTableView indexPathForSelectedRow] row]];
}

@end
