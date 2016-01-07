//
//  FeatureDetailEditViewController.m
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/28/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import "AddPropertyViewController.h"
#import "AppDelegate.h"
#import "FeatureDetailEditViewController.h"
#import <spatialconnect/SCMapKitExtensions.h>
#import <spatialconnect/SCPoint.h>
#import <spatialconnect/SCPolygon.h>

@interface FeatureDetailEditViewController ()

@end

@implementation FeatureDetailEditViewController

@synthesize geometry, labelStore, labelLayer, labelFeature, mapView, keys,
    crossHairView;

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.labelStore setText:self.geometry.key.storeId];
  [self.labelLayer setText:self.geometry.key.layerId];
  [self.labelFeature setText:self.geometry.key.featureId];
  self.mapView.userInteractionEnabled = NO;
  [self addGeometryToMap];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.keys = [[NSArray alloc] initWithArray:[geometry.properties allKeys]];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.tableViewProps reloadData];
}

- (void)addGeometryToMap {
  if ([geometry isKindOfClass:[SCPoint class]]) {
    SCPoint *p = (SCPoint *)self.geometry;
    MKPointAnnotation *pa = p.shape;
    [self.mapView addAnnotation:pa];
    [self zoomAndCenterOnSelection:p.coordinate];

    @weakify(self);
    [[self rac_signalForSelector:@selector(mapView:regionDidChangeAnimated:)
                    fromProtocol:@protocol(MKMapViewDelegate)]
        subscribeNext:^(RACTuple *t) {
          @strongify(self);
          [pa setCoordinate:self.mapView.centerCoordinate];
          [p setX:self.mapView.centerCoordinate.longitude];
          [p setY:self.mapView.centerCoordinate.latitude];
        }];

  } else if ([geometry isKindOfClass:[SCLineString class]]) {
    SCLineString *p = (SCLineString *)self.geometry;
    [self.mapView addAnnotation:p.shape];
  } else if ([geometry isKindOfClass:[SCPolygon class]]) {
    SCPolygon *p = (SCPolygon *)self.geometry;
    [self.mapView addAnnotation:p.shape];
  }
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

- (IBAction)buttonPressMoveGeometry:(id)sender {
  self.mapView.userInteractionEnabled = YES;
}

- (void)addImage {
  UIImage *img = [UIImage imageNamed:@"crossHair.png"];
  UIImageView *v = [[UIImageView alloc] initWithImage:img];
  v.frame = CGRectMake(self.mapView.frame.size.width / 2 - 25,
                       self.mapView.frame.size.height / 2 - 25, 50, 50);
  v.userInteractionEnabled = NO;
  [self.mapView addSubview:v];
}

- (IBAction)buttonPressAddProperty:(id)sender {
  AddPropertyViewController *pvc =
      [[AddPropertyViewController alloc] initWithNibName:@"AddPropertyView"
                                                  bundle:nil];
  pvc.geometry = self.geometry;
  [self presentViewController:pvc animated:YES completion:nil];
}

- (IBAction)buttonPressSave:(id)sender {
  AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  SpatialConnect *sc = [d spatialConnectSharedInstance];
  SCDataStore *ds =
      [sc.manager.dataService storeByIdentifier:geometry.key.storeId];
  id<SCSpatialStore> ss = (id<SCSpatialStore>)ds;

  @weakify(self);
  [[ss update:self.geometry] subscribeError:^(NSError *error) {
    NSLog(@"Error");
  }
      completed:^{
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
      }];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return self.geometry.properties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:@"FeatureDetail"];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:@"FeatureDetail"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  NSString *key = [self.keys objectAtIndex:indexPath.row];
  NSObject *val = [self.geometry.properties objectForKey:key];
  cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", key, val];
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
  NSString *key = [self.keys objectAtIndex:indexPath.row];
  NSObject *o = [self.geometry.properties objectForKey:key];
  if (!([o isKindOfClass:[NSString class]] ||
        [o isKindOfClass:[NSNumber class]])) {
    return;
  }

  if ([key isEqualToString:@"id"]) {
    return;
  }

  AddPropertyViewController *pvc =
      [[AddPropertyViewController alloc] initWithNibName:@"AddPropertyView"
                                                  bundle:nil];
  pvc.geometry = self.geometry;
  pvc.key = key;
  pvc.value = o;

  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [self presentViewController:pvc animated:YES completion:nil];
}

- (void)drawCrossHair {
  CGFloat offset = 0;
  CGFloat ratio =
      crossHairView.frame.size.width / crossHairView.frame.size.height;

  CGContextRef context = CGBitmapContextCreate(
      nil, crossHairView.frame.size.width, crossHairView.frame.size.height, 8,
      4 * crossHairView.frame.size.width, CGColorSpaceCreateDeviceRGB(),
      kCGImageAlphaPremultipliedLast);

  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
  CGContextSetLineWidth(context, 2.5);

  // Draw Horizontal Line
  CGContextMoveToPoint(context, 0 + offset,
                       crossHairView.frame.size.height / 2);
  CGContextAddLineToPoint(context, crossHairView.frame.size.width - offset,
                          crossHairView.frame.size.height / 2);
  CGContextStrokePath(context);

  // Draw Vertical Line
  CGContextMoveToPoint(context, crossHairView.frame.size.width / 2,
                       0 + offset / ratio);
  CGContextAddLineToPoint(context, crossHairView.frame.size.width / 2,
                          crossHairView.frame.size.height - offset / ratio);
  CGContextStrokePath(context);

  ///////////////////////////////Second Line////////////////////////////

  CGContextSetStrokeColorWithColor(
      context, [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8].CGColor);
  CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
  CGContextSetLineWidth(context, 1.0);

  // Draw Horizontal Line
  CGContextMoveToPoint(context, 0 + offset,
                       crossHairView.frame.size.height / 2);
  CGContextAddLineToPoint(context, crossHairView.frame.size.width - offset,
                          crossHairView.frame.size.height / 2);
  CGContextStrokePath(context);

  // Draw Vertical Line
  CGContextMoveToPoint(context, crossHairView.frame.size.width / 2,
                       0 + offset / ratio);
  CGContextAddLineToPoint(context, crossHairView.frame.size.width / 2,
                          crossHairView.frame.size.height - offset / ratio);
  CGContextStrokePath(context);

  CGImageRef image = CGBitmapContextCreateImage(context);
  UIImage *img = [UIImage imageWithCGImage:image];

  crossHairView.image = img;
  CGContextRelease(context);
}

@end
