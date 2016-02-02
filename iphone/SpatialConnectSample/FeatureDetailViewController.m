//
//  FeatureDetailViewController.m
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/28/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import "AppDelegate.h"
#import "FeatureDetailEditViewController.h"
#import "FeatureDetailViewController.h"
#import <spatialconnect/SCPoint.h>

@interface FeatureDetailViewController ()

@end

@implementation FeatureDetailViewController

@synthesize geometry, labelAltitude, labelFeature, labelLatitude, labelLayer,
    labelLongitude, labelStore, keys, tableViewProperties, buttonEdit, sc;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.keys = [[NSArray alloc] initWithArray:[geometry.properties allKeys]];
  [self.labelFeature setText:geometry.key.featureId];
  [self.labelLatitude
      setText:[NSString stringWithFormat:@"%.20lf", geometry.centroid.y]];
  [self.labelLongitude
      setText:[NSString stringWithFormat:@"%.20lf", geometry.centroid.x]];
  [self.labelLayer setText:geometry.key.layerId];
  [self.labelStore setText:geometry.key.storeId];

  AppDelegate *del =
      (AppDelegate *)[[UIApplication sharedApplication] delegate];
  self.sc = [del spatialConnectSharedInstance];
  SCDataStore *ds =
      [sc.manager.dataService storeByIdentifier:self.geometry.storeId];
  if (ds.permission == SC_DATASTORE_READWRITE) {
    self.buttonEdit.enabled = YES;
    self.buttonDelete.enabled = YES;
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.tableViewProperties reloadData];
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

- (IBAction)buttonPressedDismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buttonPressedEdit:(id)sender {

  FeatureDetailEditViewController *vc = [[FeatureDetailEditViewController alloc]
      initWithNibName:@"FeatureDetailEditView"
               bundle:nil];
  vc.geometry = self.geometry;
  [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)buttonPressDelete:(id)sender {
  SCDataStore *ds =
      [sc.manager.dataService storeByIdentifier:self.geometry.storeId];
  id<SCSpatialStore> ss = (id<SCSpatialStore>)ds;
  [[[ss delete:self.geometry.key] deliverOn:[RACScheduler mainThreadScheduler]]
      subscribeError:^(NSError *error) {
        NSLog(@"Error");
      }
      completed:^{
        [self.navigationController dismissViewControllerAnimated:YES
                                                      completion:nil];
      }];
}
@end
