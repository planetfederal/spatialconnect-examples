//
//  DataStoreDetailViewController.m
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/21/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import "DataStoreDetailViewController.h"

@interface DataStoreDetailViewController ()

@end

@implementation DataStoreDetailViewController

@synthesize store;

- (void)viewDidLoad {
    [super viewDidLoad];
  if (store) {
    self.labelStoreId.text = store.storeId;
    self.labelStoreName.text = store.name;
    self.labelStoreType.text = store.type;
    self.labelStoreVersion.text = [NSString stringWithFormat:@"%ld",store.version];
    NSString *status;
    switch (store.status) {
      case SC_DATASTORE_DOWNLOADINGDATA:
        status = @"Downloading Data...";
        break;
      case SC_DATASTORE_STARTED:
        status = @"Started";
        break;
      case SC_DATASTORE_PAUSED:
        status = @"Paused";
        break;
      case SC_DATASTORE_RUNNING:
        status = @"Running";
        break;
      case SC_DATASTORE_STOPPED:
        status = @"Stopped";
        break;
      default:
        status = @"";
        break;
    }
    self.labelStoreStatus.text = status;
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
