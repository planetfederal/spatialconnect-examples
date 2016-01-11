//
//  SecondViewController.h
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/19/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MapKit;

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property(nonatomic, weak) IBOutlet MKMapView *mapView;
@property(nonatomic, weak) SpatialConnect *sc;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) NSCache *cacheAnnotations;
@property(nonatomic, strong) NSMutableDictionary *rasters;
@property(nonatomic, strong) NSMutableDictionary *vectors;
@property(nonatomic, strong) RACDisposable *disposableMapRefresh;
@property(weak, nonatomic) IBOutlet UIButton *buttonSearch;
@property(weak, nonatomic) IBOutlet UIButton *buttonImagery;
- (IBAction)buttonPressAddFeature:(id)sender;
- (IBAction)buttonPressSearch:(id)sender;
- (IBAction)buttonPressLoadImagery:(id)sender;

@end
