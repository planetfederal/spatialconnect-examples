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


#import "MapViewController.h"
#import "AppDelegate.h"
#import <SpatialConnect/SpatialConnect.h>
#import <SpatialConnect/SCFileUtils.h>
#import <SpatialConnect/SCStyle.h>
#import <SpatialConnect/GeoJSONStore.h>
#import <SpatialConnect/GeoJSONAdapter.h>
#import <SpatialConnect/SCMapKitExtensions.h>
#import <SpatialConnect/SCGeometryCollection+MapKit.h>
#import <SpatialConnect/SCTileOverlay.h>
#import <SpatialConnect/SCTileOverlayRenderer.h>
#import <SpatialConnect/SCOpenStreetMapSource.h>

@interface MapViewController ()

@property (nonatomic,assign) MapViewModel *viewModel;
@property (nonatomic,retain) MKTileOverlay *testOverlay;

@end

@implementation MapViewController

@synthesize spatialConnect;

-(instancetype)initWithViewModel:(MapViewModel *)viewModel {
  self = [self init];
  if (!self) return nil;
  self.viewModel = viewModel;
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  __block BOOL applySecond = NO;
  
  SCStyle *style = [[SCStyle alloc] init];
  style.fillColor = [UIColor yellowColor];
  style.fillOpacity = 0.25f;
  style.strokeColor = [UIColor greenColor];
  style.strokeOpacity = 0.5f;
  style.strokeWidth = 4;
  
  SCStyle *style2 = [[SCStyle alloc] init];
  style2.fillColor = [UIColor blueColor];
  style2.fillOpacity = 0.2f;
  style2.strokeColor = [UIColor purpleColor];
  style2.strokeWidth = 5;
  style2.strokeOpacity = 0.6f;
  AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  self.spatialConnect = [appDelegate spatialConnectSharedInstance];

  [[[self.spatialConnect.manager.sensorService lastKnown] filter:^BOOL(SCPoint *point) {
    SCBoundingBox *bbox = [[SCBoundingBox alloc] init];
    if ([bbox pointWithin:point ]) {
      return YES;
    }
    return NO;
  }] subscribeNext:^(SCPoint *point) {
    NSLog(@"Point withing bounding box: %@",[point description]);
  }];
  
  @weakify(self);
  [[[[self.spatialConnect.manager.dataService queryAllStores:nil] map:^SCGeometryCollection*(SCGeometry *geom) {
    if ([geom isKindOfClass:SCGeometry.class]) {
      SCGeometryCollection *gc = (SCGeometryCollection*)geom;
      if (!applySecond) {
        [gc applyStyle:style];
        applySecond = YES;
      } else {
        [gc applyStyle:style2];
      }
    }
    return (SCGeometryCollection*)geom;
  }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(SCGeometryCollection *g) {
    @strongify(self);
    [g addToMap:self.mapView];
  }];
  
  [self.mapView setShowsUserLocation:YES];
  self.testOverlay = [[SCTileOverlay alloc] initWithRasterSource:[[SCOpenStreetMapSource alloc] init]];
  self.testOverlay.canReplaceMapContent = YES;
  [self.mapView addOverlay:self.testOverlay level:MKOverlayLevelAboveLabels];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark MapViewDelegate Methods
-(MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  if ([overlay isKindOfClass:[SCPolygon class]]) {
    SCPolygon *poly = (SCPolygon*)overlay;
    MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithPolygon:[poly shape]];
    renderer.strokeColor = poly.style.strokeColor;
    renderer.fillColor = poly.style.fillColor;
    renderer.lineWidth = poly.style.strokeWidth;
    return renderer;
  } else if([overlay isKindOfClass:[SCLineString class]]) {
    SCLineString *line = (SCLineString*)overlay;
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:[line shape]];
    renderer.lineWidth = line.style.strokeWidth;
    renderer.strokeColor = line.style.strokeColor;
    return renderer;
  } else if([overlay isKindOfClass:[MKPolygon class]]) {
    MKPolygonRenderer *ren = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
    ren.strokeColor = [UIColor redColor];
    ren.lineWidth = 5.0f;
    return ren;
  } else if ([overlay isKindOfClass:[MKTileOverlay class]]) {
    MKTileOverlay *tileOverlay = (MKTileOverlay*)overlay;
    MKTileOverlayRenderer *renderer = nil;
    if ([tileOverlay isKindOfClass:SCTileOverlay.class]) {
      renderer = [[SCTileOverlayRenderer alloc] initWithTileOverlay:tileOverlay];
    }
    return renderer;
  }
  return nil;
}

@end
