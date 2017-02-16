//
//  JSCPlugin.m
//  JSCoreBridge
//
//  Created by iPhuan on 2016/11/29.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import "JSCPlugin.h"

@interface JSCPlugin ()

@property (nonatomic, readwrite, weak) UIWebView *webView;
@property (nonatomic, readwrite, weak) JSCWebViewController *webViewController;
@property (nonatomic, readwrite, weak) id <JSCBridgeDelegate> bridgeDelegate;


@end

@implementation JSCPlugin


- (instancetype)initWithWebViewController:(JSCWebViewController *)webViewController{
    self = [super init];
    if (self) {
        _webViewController = webViewController;
        _webView = webViewController.webView;
        _bridgeDelegate = webViewController.bridgeDelegate;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppTerminate) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)pluginDidInitialize{
    // Do someting you need after plugin init
    
    // You can listen to more app notifications, see:
    
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPause) name:UIApplicationDidEnterBackgroundNotification object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (BOOL)canCallPlugin{
    // Override this if you need to forbid call plugin
    return YES;
}


- (void)onMemoryWarning{
    // Override to remove caches, etc
}

- (void)onAppTerminate{
    // Override this if you need to do any cleanup on app exit
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
