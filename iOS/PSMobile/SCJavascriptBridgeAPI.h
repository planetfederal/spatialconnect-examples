//
//  SCJavascriptBridgeAPI.h
//  SpatialConnect
//
//  Created by Wes Richardet on 10/9/15.
//  Copyright © 2015 Boundless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpatialConnect/WebViewJavascriptBridge.h>

@interface SCJavascriptBridgeAPI : NSObject

@property(strong, nonatomic) UIWebView *webview;
@property(strong, nonatomic) NSObject<UIWebViewDelegate> *webViewDelegate;
@property(strong, nonatomic) WebViewJavascriptBridge *bridge;

- (id)initWithWebView:(UIWebView *)webView
          andDelegate:(NSObject<UIWebViewDelegate> *)delegate;

@end
