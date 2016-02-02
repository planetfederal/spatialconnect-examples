//
//  FirstViewController.m
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/19/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import "DataStoreViewController.h"
#import "AppDelegate.h"
#import "DataStoreDetailViewController.h"

@interface DataStoreViewController ()
@property (nonatomic,readwrite) NSMutableArray *stores;
@end

@implementation DataStoreViewController

@synthesize stores = _stores;

- (void)viewDidLoad {
  [super viewDidLoad];
  AppDelegate *d = [[UIApplication sharedApplication] delegate];
  SpatialConnect *s = d.spatialConnectSharedInstance;
  RACMulticastConnection *c = s.manager.dataService.storeEvents;
  self.stores = [s.manager.dataService storeList];
  [c connect];
  [[c.signal deliverOnMainThread] subscribeNext:^(SCStoreStatusEvent *se) {
    [self.tableView reloadData];
  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.stores.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DataStoreCell" forIndexPath:indexPath];

  SCDataStore *d = (SCDataStore*)[self.stores objectAtIndex:indexPath.row];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.textLabel.text = d.name;

  switch(d.status) {
    case SC_DATASTORE_STARTED:
      cell.detailTextLabel.text = @"Starting";
      break;
    case SC_DATASTORE_PAUSED:
      cell.detailTextLabel.text = @"Paused";
      break;
    case SC_DATASTORE_RUNNING:
      cell.detailTextLabel.text = @"Running";
      break;
    case SC_DATASTORE_STOPPED:
      cell.detailTextLabel.text = @"Stopped";
      break;
    case SC_DATASTORE_DOWNLOADINGDATA:
      cell.detailTextLabel.text = @"Downloading...";
      break;
    default:
      cell.detailTextLabel.text = @"";
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSIndexPath *path = [self.tableView indexPathForSelectedRow];
  SCDataStore *ds = [self.stores objectAtIndex:path.row];

  DataStoreDetailViewController *vc = (DataStoreDetailViewController*) segue.destinationViewController;
  vc.store = ds;
}



@end
