//
//  SCJavascriptBridgeAPI.m
//  SpatialConnect
//
//  Created by Wes Richardet on 10/9/15.
//  Copyright © 2015 Boundless. All rights reserved.
//

#import "SCJavascriptBridgeAPI.h"

@implementation SCJavascriptBridgeAPI

- (id)initWithWebView:(UIWebView *)webView
          andDelegate:(NSObject<UIWebViewDelegate> *)delegate {
  if (self = [super init]) {
    self.webview = webView;
    self.webViewDelegate = delegate;

    self.bridge = [WebViewJavascriptBridge
        bridgeForWebView:self.webview
         webViewDelegate:self.webViewDelegate
                 handler:^(id data, WVJBResponseCallback responseCallback) {
                   NSLog(@"Hey, how are you");
                 }];
  }
  return self;
}

@end
