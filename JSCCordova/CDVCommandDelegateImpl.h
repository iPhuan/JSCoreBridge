//
//  CDVCommandDelegateImpl.h
//  JSCCordova
//
//  Created by iPhuan on 2017/2/19.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "JSCBridgeDelegateImpl.h"

NS_ASSUME_NONNULL_BEGIN

@class CDVPluginResult;
@class CDVPlugin;

@interface JSCBridgeDelegateImpl (CDVCommandDelegateImpl)

- (nullable __kindof JSCPlugin *)getCommandInstance:(NSString *)pluginName;
- (void)sendPluginResult:(CDVPluginResult *)result callbackId:(NSString *)callbackId;

@end

NS_ASSUME_NONNULL_END

