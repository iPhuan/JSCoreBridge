//
//  CDVViewController.h
//  JSCCordova
//
//  Created by iPhuan on 2017/2/19.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "JSCWebViewController.h"
#import "CDVPluginResult.h"
#import "CDVCommandDelegateImpl.h"
#import "CDVInvokedUrlCommand.h"

#define JSC_CORDOVA_VERSION  

NS_ASSUME_NONNULL_BEGIN

@class CDVPlugin;

@interface CDVViewController : JSCWebViewController

@property (nonatomic, copy, nullable) NSString *configFile;
@property (nonatomic, readonly, weak) id commandDelegate;

- (nullable __kindof JSCPlugin *)getCommandInstance:(NSString *)pluginName;
- (void)registerPlugin:(CDVPlugin *)plugin withPluginName:(NSString *)pluginName;

@end

NS_ASSUME_NONNULL_END

