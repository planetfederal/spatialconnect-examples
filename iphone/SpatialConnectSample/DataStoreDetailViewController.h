//
//  DataStoreDetailViewController.h
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/21/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <spatialconnect/SCDataStore.h>
@interface DataStoreDetailViewController : UIViewController
@property (nonatomic,weak) SCDataStore *store;
@property (weak, nonatomic) IBOutlet UILabel *labelStoreId;
@property (weak, nonatomic) IBOutlet UILabel *labelStoreName;
@property (weak, nonatomic) IBOutlet UILabel *labelStoreType;
@property (weak, nonatomic) IBOutlet UILabel *labelStoreVersion;
@property (weak, nonatomic) IBOutlet UILabel *labelStoreStatus;
@end
