//
//  SecondViewController.m
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/19/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import "AppDelegate.h"
#import "FeatureDetailViewController.h"
#import "MapViewController.h"
#import <spatialconnect/SCGeoFilterContains.h>
#import <spatialconnect/SCGeometryCollection+MapKit.h>
#import <spatialconnect/SCMapKitExtensions.h>

@interface MapViewController ()
- (SCBoundingBox *)currentViewBoundingBox;
@end

@implementation MapViewController

@synthesize mapView;
@synthesize cacheAnnotations;
@synthesize disposableMapRefresh;
@synthesize buttonSearch;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.cacheAnnotations = [NSCache new];

  AppDelegate *ad = [[UIApplication sharedApplication] delegate];
  self.sc = [ad spatialConnectSharedInstance];

  self.mapView.delegate = self;
}

- (void)handleMapTap:(UIGestureRecognizer *)tap {
  CGPoint tapPoint = [tap locationInView:self.mapView];

  CLLocationCoordinate2D tapCoord =
      [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
  MKMapPoint mapPoint = MKMapPointForCoordinate(tapCoord);
  CGPoint mapPointAsCGP = CGPointMake(mapPoint.x, mapPoint.y);

  for (id<MKOverlay> overlay in self.mapView.overlays) {
    if ([overlay isKindOfClass:[SCPolygon class]]) {
      SCPolygon *polygon = (SCPolygon *)overlay;
      CGMutablePathRef mpr = CGPathCreateMutable();
      [polygon.points
          enumerateObjectsUsingBlock:^(SCPoint *p, NSUInteger idx, BOOL *stop) {
            MKMapPoint mp = MKMapPointMake(p.x, p.y);
            if (idx == 0)
              CGPathMoveToPoint(mpr, NULL, p.x, p.y);
            else
              CGPathAddLineToPoint(mpr, NULL, mp.x, mp.y);
          }];

      if (CGPathContainsPoint(mpr, NULL, mapPointAsCGP, FALSE)) {
        NSLog(@"YO");
      }

      CGPathRelease(mpr);
    }
  }
}

- (void)displayTiles {
  id<SCRasterStore> ss = (id<SCRasterStore>)[self.sc.manager.dataService
      storeByIdentifier:@"ba293796-5026-46f7-a2ff-e5dec85heh6b"];
  [ss overlayFromLayer:@"WhiteHorse" mapview:self.mapView];
}

- (void)clearMap {
  [self.mapView removeOverlays:self.mapView.overlays];
  [self.mapView removeAnnotations:self.mapView.annotations];
}

- (SCBoundingBox *)currentViewBoundingBox {
  MKMapRect mRect = self.mapView.visibleMapRect;
  MKMapPoint neMapPoint =
      MKMapPointMake(MKMapRectGetMaxX(mRect), mRect.origin.y);
  MKMapPoint swMapPoint =
      MKMapPointMake(mRect.origin.x, MKMapRectGetMaxY(mRect));
  CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
  CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
  SCBoundingBox *bbox = [[SCBoundingBox alloc] init];
  [bbox setUpperRight:[SCPoint pointFromCLLocationCoordinate2D:neCoord]];
  [bbox setLowerLeft:[SCPoint pointFromCLLocationCoordinate2D:swCoord]];
  return bbox;
}

- (void)zoomAndCenterOnSelection:(CLLocationCoordinate2D)coord {
  MKCoordinateRegion region = self.mapView.region;
  MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
  region.center = coord;

  region.center.latitude -= self.mapView.region.span.latitudeDelta *
                            span.latitudeDelta / region.span.latitudeDelta *
                            0.5;

  region.span.longitudeDelta = 1.0;
  region.span.latitudeDelta = 1.0;

  [self.mapView setRegion:region animated:YES];
}

- (void)populateMap:(SCBoundingBox *)bbox {
  [self displayTiles];
  //  CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(60.86, -135.19);
  //  [self zoomAndCenterOnSelection:coord];

  SCQueryFilter *filter = [[SCQueryFilter alloc] init];
  if (bbox) {
    SCGeoFilterContains *gfc = [[SCGeoFilterContains alloc] initWithBBOX:bbox];
    SCPredicate *predicate = [[SCPredicate alloc] initWithFilter:gfc];
    [filter addPredicate:predicate];
  }
  filter.limit = 100;

  SCStyle *style1 = [[SCStyle alloc] init];
  style1.fillOpacity = 1.0f;
  style1.strokeColor = [UIColor greenColor];
  style1.strokeWidth = 1;

  SCStyle *style2 = [[SCStyle alloc] init];
  style2.fillOpacity = 1.0f;
  style2.strokeColor = [UIColor redColor];
  style2.strokeWidth = 1;

  SCStyle *style3 = [[SCStyle alloc] init];
  style3.fillOpacity = 1.0f;
  style3.strokeColor = [UIColor orangeColor];
  style3.strokeWidth = 1;

  SCStyle *style4 = [[SCStyle alloc] init];
  style4.fillOpacity = 1.0f;
  style4.strokeColor = [UIColor purpleColor];
  style4.strokeWidth = 1;
  __block NSMutableDictionary *styleDict = [NSMutableDictionary new];
  NSArray *styles = @[ style1, style2, style3, style4 ];
  [[self.sc.manager.dataService activeStoreList]
      enumerateObjectsUsingBlock:^(SCDataStore *ds, NSUInteger idx,
                                   BOOL *_Nonnull stop) {
        [styleDict setObject:styles[idx] forKey:ds.storeId];
      }];

  [self.mapView removeAnnotations:self.mapView.annotations];
  [self.mapView removeOverlays:self.mapView.overlays];

  @weakify(self);

  [[[[self.sc.manager.dataService queryAllStores:filter]
      map:^SCGeometry *(SCGeometry *geom) {
        if ([geom isKindOfClass:SCGeometry.class]) {
          geom.style = [styleDict objectForKey:geom.key.storeId];
        }
        return geom;
      }] deliverOn:[RACScheduler mainThreadScheduler]]
      subscribeNext:^(SCGeometry *g) {
        @strongify(self);
        [g addToMap:self.mapView];
      }
      completed:^{
        self.buttonSearch.enabled = YES;
      }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark MapViewDelegate Methods
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay {
  if ([overlay isKindOfClass:[SCPolygon class]]) {
    SCPolygon *poly = (SCPolygon *)overlay;
    MKPolygonRenderer *renderer =
        [[MKPolygonRenderer alloc] initWithPolygon:[poly shape]];
    renderer.strokeColor = poly.style.strokeColor;
    renderer.fillColor = poly.style.fillColor;
    renderer.lineWidth = poly.style.strokeWidth;
    return renderer;
  } else if ([overlay isKindOfClass:[SCLineString class]]) {
    SCLineString *line = (SCLineString *)overlay;
    MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithPolyline:[line shape]];
    renderer.lineWidth = line.style.strokeWidth;
    renderer.strokeColor = line.style.strokeColor;
    return renderer;
  } else if ([overlay isKindOfClass:[MKPolygon class]]) {
    MKPolygonRenderer *ren =
        [[MKPolygonRenderer alloc] initWithOverlay:overlay];
    ren.strokeColor = [UIColor redColor];
    ren.lineWidth = 2.0f;
    return ren;
  }
  //  else if ([overlay isKindOfClass:[MKTileOverlay class]]) {
  //    MKTileOverlay *tileOverlay = (MKTileOverlay*)overlay;
  //    MKTileOverlayRenderer *renderer = nil;
  //    if ([tileOverlay isKindOfClass:SCTileOverlay.class]) {
  //      renderer = [[SCTileOverlayRenderer alloc]
  //      initWithTileOverlay:tileOverlay];
  //    }
  //    return renderer;
  //  }
  else if ([overlay isKindOfClass:[MKTileOverlay class]]) {
    return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
  }

  return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
  MKAnnotationView *returnedAnnotationView = nil;
  if ([annotation isKindOfClass:SCPoint.class]) {
    SCPoint *p = (SCPoint *)annotation;
    returnedAnnotationView =
        [p createViewAnnotationForMapView:self.mapView annotation:annotation];

    UIButton *rightButton =
        [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    returnedAnnotationView.rightCalloutAccessoryView = rightButton;
  }
  return returnedAnnotationView;
}

- (void)mapView:(MKMapView *)mapView
                   annotationView:(MKAnnotationView *)view
    calloutAccessoryControlTapped:(UIControl *)control {
  FeatureDetailViewController *fdvc =
      [[FeatureDetailViewController alloc] initWithNibName:@"FeatureDetailView"
                                                    bundle:nil];
  fdvc.geometry = view.annotation;
  [self.navigationController pushViewController:fdvc animated:YES];
}

- (IBAction)buttonPressAddFeature:(id)sender {
  CLLocationCoordinate2D coord = self.mapView.centerCoordinate;
  NSArray *arr = @[ @(coord.longitude), @(coord.latitude) ];
  SCPoint *p = [[SCPoint alloc] initWithCoordinateArray:arr];
  id<SCSpatialStore> scss = (id<SCSpatialStore>)[self.sc.manager.dataService
      storeByIdentifier:@"a5d93796-5026-46f7-a2ff-e5dec85heh6b"];
  [[[scss create:p] subscribeOn:[RACScheduler mainThreadScheduler]]
      subscribeCompleted:^{
        NSLog(@"Point Created");
        [self.mapView addAnnotation:p.shape];
      }];
}

- (IBAction)buttonPressSearch:(id)sender {
  self.buttonSearch.enabled = NO;
  [self populateMap:self.currentViewBoundingBox];
}
@end
