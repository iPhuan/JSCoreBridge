//
//  CDVCommandDelegateImpl.m
//  JSCCordova
//
//  Created by iPhuan on 2017/2/19.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "CDVCommandDelegateImpl.h"
#import "CDVPluginResult.h"

@implementation JSCBridgeDelegateImpl (CDVCommandDelegateImpl)

- (nullable __kindof JSCPlugin *)getCommandInstance:(NSString *)pluginName {
    return [self getPluginInstance:pluginName];
}

- (void)sendPluginResult:(CDVPluginResult *)result callbackId:(NSString *)callbackId {
    [self sendPluginResult:result forCallbackId:callbackId];
}

@end
