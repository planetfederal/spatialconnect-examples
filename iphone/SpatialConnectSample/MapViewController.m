//
//  SecondViewController.m
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/19/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import <spatialconnect/SCMapKitExtensions.h>
#import <spatialconnect/SCGeometryCollection+MapKit.h>
#import <spatialconnect/SCGeoFilterContains.h>

@interface MapViewController ()
- (SCBoundingBox*)currentViewBoundingBox;
@end

@implementation MapViewController

@synthesize mapView;

- (void)viewDidLoad {
  [super viewDidLoad];
  AppDelegate *ad = [[UIApplication sharedApplication] delegate];
  self.sc = [ad spatialConnectSharedInstance];

  self.mapView.delegate = self;
  RACSignal *userInteraction = [[self rac_signalForSelector:@selector(mapView:regionWillChangeAnimated:) fromProtocol:@protocol(MKMapViewDelegate)] filter:^BOOL(RACTuple *t) {
    MKMapView *mv = (MKMapView*)t.first;
    UIView* view = mv.subviews.firstObject;

    for(UIGestureRecognizer* recognizer in view.gestureRecognizers)
    {
      if(recognizer.state == UIGestureRecognizerStateBegan
         || recognizer.state == UIGestureRecognizerStateEnded)
      {
        return YES;
      }
    }
    return NO;
  }];

  RACSignal *mapChanged = [self rac_signalForSelector:@selector(mapView:regionDidChangeAnimated:)
                                          fromProtocol:@protocol(MKMapViewDelegate)];

  [[userInteraction combineLatestWith:mapChanged] subscribeNext:^(RACTuple *t) {
      [self populateMap:self.currentViewBoundingBox];
  }];

  [self populateMap:self.currentViewBoundingBox];
}

- (SCBoundingBox*)currentViewBoundingBox {
  MKMapRect mRect = self.mapView.visibleMapRect;
  MKMapPoint neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), mRect.origin.y);
  MKMapPoint swMapPoint = MKMapPointMake(mRect.origin.x, MKMapRectGetMaxY(mRect));
  CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
  CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
  SCBoundingBox *bbox = [[SCBoundingBox alloc] init];
  [bbox setUpperRight:[SCPoint pointFromCLLocationCoordinate2D:neCoord]];
  [bbox setLowerLeft:[SCPoint pointFromCLLocationCoordinate2D:swCoord]];
  return bbox;
}

- (void)populateMap:(SCBoundingBox*)bbox {
  SCQueryFilter *filter = [[SCQueryFilter alloc] init];
  if (bbox) {
    SCGeoFilterContains *gfc = [[SCGeoFilterContains alloc] initWithBBOX:bbox];
    SCPredicate *predicate = [[SCPredicate alloc] initWithFilter:gfc];
    [filter addPredicate:predicate];
  }
  filter.limit = 30;

  SCStyle *style = [[SCStyle alloc] init];
  style.fillOpacity = 1.0f;
  style.strokeColor = [UIColor greenColor];
  style.strokeWidth = 1;

  @weakify(self);
  id<SCSpatialStore> ss = (id<SCSpatialStore>)[self.sc.manager.dataService storeByIdentifier:@"a5d93796-5026-46f7-a2ff-e5dec85heh6b"];
  [[[[ss query:filter]
     map:^SCGeometry*(SCGeometry *geom) {
    if ([geom isKindOfClass:SCGeometry.class]) {
        geom.style = style;
    }
    return geom;
  }] subscribeOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(SCGeometry *g) {
    @strongify(self);
    [g addToMap:self.mapView];
  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
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
    ren.lineWidth = 2.0f;
    return ren;
  }
//  else if ([overlay isKindOfClass:[MKTileOverlay class]]) {
//    MKTileOverlay *tileOverlay = (MKTileOverlay*)overlay;
//    MKTileOverlayRenderer *renderer = nil;
//    if ([tileOverlay isKindOfClass:SCTileOverlay.class]) {
//      renderer = [[SCTileOverlayRenderer alloc] initWithTileOverlay:tileOverlay];
//    }
//    return renderer;
//  }
  return nil;
}

@end
