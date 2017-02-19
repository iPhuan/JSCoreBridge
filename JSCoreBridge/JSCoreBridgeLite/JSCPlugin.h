//
//  JSCPlugin.h
//  JSCoreBridge
//
//  Created by iPhuan on 2016/11/29.
//  Copyright © 2016年 iPhuan. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "JSCWebViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface JSCPlugin : NSObject
@property (nonatomic, readonly, weak) UIWebView *webView;
@property (nonatomic, readonly, weak) JSCWebViewController *webViewController;
@property (nonatomic, readonly, weak) id <JSCBridgeDelegate> bridgeDelegate; //Use this property to call 'JSCBridgeDelegate' methods
@property (nonatomic, copy) NSString * _Nullable backupCallbackId;   //Use this property to save the callbackId if you need to keep callback

- (instancetype)initWithWebViewController:(JSCWebViewController *)webViewController;

// Do someting you need after plugin init
- (void)pluginDidInitialize;

// Override this if you need to forbid call plugin
- (BOOL)canCallPlugin;

// Override to remove caches, etc
- (void)onMemoryWarning;

// Override this if you need to do any cleanup on app exit
- (void)onAppTerminate;

@end

NS_ASSUME_NONNULL_END
