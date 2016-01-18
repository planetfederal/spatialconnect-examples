//
//  WebDownloadViewController.m
//  SpatialConnectSample
//
//  Created by Wes Richardet on 1/13/16.
//  Copyright © 2016 Boundless Spatial. All rights reserved.
//

#import "WebDownloadViewController.h"
#import "WebMapViewController.h"

@implementation WebDownloadViewController

@synthesize textFieldWeb;

- (IBAction)buttonPressDownload:(id)sender {
  NSString *text = self.textFieldWeb.text;
  NSURL *url = [NSURL URLWithString:text];
  NSString *path;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  path = [documentsDirectory stringByAppendingPathComponent:@"web.zip"];

  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  RACSignal *download = [[NSURLConnection rac_sendAsynchronousRequest:request]
      reduceEach:^id(NSURLResponse *response, NSData *data) {
        return data;
      }];

  [[[download map:^id(id data) {
    [data writeToFile:path atomically:YES];
    return nil;
  }] deliverOn:[RACScheduler mainThreadScheduler]]
      subscribeNext:^(NSData *data) {
        WebMapViewController *wmvc =
            [[WebMapViewController alloc] initWithNibName:@"WebMapView"
                                                   bundle:nil];
        wmvc.zipFilePath = path;
        [self.navigationController pushViewController:wmvc animated:YES];
      }];
}

@end
