//
//  AddPropertyViewController.h
//  SpatialConnectSample
//
//  Created by Wes Richardet on 12/31/15.
//  Copyright © 2015 Boundless Spatial. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPropertyViewController : UIViewController

@property(strong, nonatomic) SCGeometry *geometry;
@property(weak, nonatomic) IBOutlet UITextField *textFieldKey;
@property(weak, nonatomic) IBOutlet UITextField *textFieldValue;
@property(nonatomic) BOOL saveEnabled;
@property(weak, nonatomic) IBOutlet UIButton *buttonSave;
@property(strong, nonatomic) NSString *key;
@property(strong, nonatomic) NSObject *value;
- (IBAction)buttonPressDismiss:(id)sender;
- (IBAction)buttonPressSave:(id)sender;

@end
