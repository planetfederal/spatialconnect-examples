//
//  FeatureDetailViewController.h
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/28/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeatureDetailViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction)buttonPressedDismiss:(id)sender;
- (IBAction)buttonPressedEdit:(id)sender;

@property(weak, nonatomic) SCGeometry *geometry;
@property(strong, nonatomic) NSArray *keys;
@property(weak, nonatomic) IBOutlet UITableView *tableViewProperties;
@property(weak, nonatomic) IBOutlet UILabel *labelStore;
@property(weak, nonatomic) IBOutlet UILabel *labelLayer;
@property(weak, nonatomic) IBOutlet UILabel *labelFeature;
@property(weak, nonatomic) IBOutlet UILabel *labelLatitude;
@property(weak, nonatomic) IBOutlet UILabel *labelLongitude;
@property(weak, nonatomic) IBOutlet UILabel *labelAltitude;
@property (weak, nonatomic) IBOutlet UIButton *buttonEdit;

@end
