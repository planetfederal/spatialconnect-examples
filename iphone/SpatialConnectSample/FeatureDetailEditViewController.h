//
//  FeatureDetailEditViewController.h
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/28/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface FeatureDetailEditViewController
    : UIViewController <MKMapViewDelegate, UITableViewDataSource,
                        UITableViewDelegate>

@property(weak, nonatomic) SCGeometry *geometry;

@property(weak, nonatomic) IBOutlet UILabel *labelStore;
@property(weak, nonatomic) IBOutlet UILabel *labelLayer;
@property(weak, nonatomic) IBOutlet UILabel *labelFeature;
@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(weak, nonatomic) IBOutlet UITableView *tableViewProps;
@property(strong, nonatomic) NSArray *keys;
@property(strong, nonatomic) UIImageView *crossHairView;

- (IBAction)buttonPressMoveGeometry:(id)sender;
- (IBAction)buttonPressAddProperty:(id)sender;
- (IBAction)buttonPressSave:(id)sender;

@end
