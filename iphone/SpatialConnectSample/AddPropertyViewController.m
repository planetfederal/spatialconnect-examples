//
//  AddPropertyViewController.m
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/31/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import "AddPropertyViewController.h"
#import "AppDelegate.h"

@interface AddPropertyViewController ()

@end

@implementation AddPropertyViewController

@synthesize geometry, textFieldKey, textFieldValue, saveEnabled, buttonSave,
    key, value;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.saveEnabled = NO;

  if (self.key != nil) {
    self.textFieldKey.text = self.key;
    self.textFieldKey.enabled = NO;
  }

  if (self.value != nil) {
    if ([self.value isKindOfClass:[NSString class]]) {
      self.textFieldValue.text = (NSString *)self.value;
    }
    if ([self.value isKindOfClass:[NSNumber class]]) {
      NSNumber *n = (NSNumber *)self.value;
      self.textFieldValue.text = [n stringValue];
    }
  }

  RAC(self, buttonSave.enabled) = [RACSignal
      combineLatest:@[
        self.textFieldKey.rac_textSignal,
        self.textFieldValue.rac_textSignal
      ]
             reduce:^(NSString *k, NSString *v) {
               return @(![k isEqualToString:@""] && ![v isEqualToString:@""]);
             }];
}

- (IBAction)buttonPressDismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buttonPressSave:(id)sender {
  AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  SpatialConnect *sc = [d spatialConnectSharedInstance];
  SCDataStore *ds =
      [sc.manager.dataService storeByIdentifier:geometry.key.storeId];
  id<SCSpatialStore> ss = (id<SCSpatialStore>)ds;
  NSString *k = self.textFieldKey.text;
  NSString *v = self.textFieldValue.text;
  [self.geometry.properties setObject:v forKey:k];

  @weakify(self);
  [[ss update:self.geometry] subscribeError:^(NSError *error) {
    NSLog(@"Error");
  }
      completed:^{
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
      }];
}

@end
