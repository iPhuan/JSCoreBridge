//
//  JSCBridge.h
//  JSCoreBridge
//
//  Created by iPhuan on 2016/12/1.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSCBridgeDelegate.h"

@class JSCWebViewController;
@class JSCPlugin;
@class JSContext;


NS_ASSUME_NONNULL_BEGIN

@interface JSCBridge : NSObject <UIWebViewDelegate>
@property (nonatomic, readonly, strong) JSContext *context;
@property (nonatomic, readonly, weak) UIWebView *webView;
@property (nonatomic, readonly, strong) id <JSCBridgeDelegate> bridgeDelegate;
@property (nonatomic, readonly, assign) BOOL isConfigEnabled;
@property (nonatomic, readonly, weak) NSString * _Nullable configFilePath;


- (instancetype)initWithWebViewController:(JSCWebViewController *)webViewController;

- (void)webViewControllerViewDidLoad;

- (void)setPluginsMap:(NSDictionary *)pluginsMap;

- (BOOL)supportsOrientation:(UIInterfaceOrientation)orientation;

- (nullable __kindof JSCPlugin *)getPluginInstance:(NSString *)pluginName;
- (void)registerPlugin:(JSCPlugin *)plugin withPluginName:(NSString *)pluginName;

- (void)loadURL:(NSURL *)URL;
- (void)loadHTMLString:(NSString *)htmlString;

NS_ASSUME_NONNULL_END


@end
