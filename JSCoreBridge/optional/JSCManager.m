//
//  JSCManager.m
//  JSCoreBridge
//
//  Created by iPhuan on 2016/12/15.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import "JSCManager.h"
#import "JSCBridge.h"
#import "JSCConfig.h"
#import "JSCPrint.h"
#import "JSCTimer.h"
#import "JSCWebViewController.h"



@interface JSCManager ()
@property (nonatomic, weak) JSCBridge *bridge;
@property (nonatomic, strong) JSCConfig *config;

@end


@implementation JSCManager

- (instancetype)initWithBridge:(JSCBridge *)bridge{
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

- (BOOL)enableManager{
    // Print some information about JSCoreBridge
    [JSCPrint print];
    
    if (_bridge.isConfigEnabled) {
        self.config = [[JSCConfig alloc] initWithPath:_bridge.configFilePath];
        if (![_config loadConfig]) {
            return NO;
        }
        [_bridge setPluginsMap:_config.pluginsMap];
        [_config setSettingsForWebView:_bridge.webView];
        
        if (_config.startupPluginNames.count > 0) {
            [JSCTimer start:@"TotalPluginStartup"];
            
            for (NSString *pluginName in _config.startupPluginNames) {
                [_bridge getPluginInstance:pluginName];
            }
            
            [JSCTimer stop:@"TotalPluginStartup"];
        }
    }
    
    return YES;
}


- (BOOL)shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType{
    if (_config) {
        return [_config shouldStartLoadWithRequest:request navigationType:navigationType];
    }else{
        return YES;
    }
}



#pragma mark - JSCTimer

+ (void)startTimer:(NSString *)name{
    [JSCTimer start:name];
}

+ (void)stopTimer:(NSString *)name{
    [JSCTimer stop:name];
}



@end
