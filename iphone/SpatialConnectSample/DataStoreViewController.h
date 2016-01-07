//
//  FirstViewController.h
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/19/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <spatialconnect/SpatialConnect.h>

@interface DataStoreViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic, readonly) NSArray *stores;
@end
