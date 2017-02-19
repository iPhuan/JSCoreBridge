//
//  CDVPluginResult.m
//  JSCCordova
//
//  Created by iPhuan on 2017/2/19.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "CDVPluginResult.h"

const NSUInteger CDVCommandStatus_OK = JSCCommandStatus_OK;
const NSUInteger CDVCommandStatus_ERROR = JSCCommandStatus_ERROR;

@implementation CDVPluginResult

+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsNSInteger:(NSInteger)theMessage {
    NSUInteger status = statusOrdinal;
    CDVPluginResult *pluginResult = [self resultWithStatus:status messageAsInteger:theMessage];
    return pluginResult;
}

+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsNSUInteger:(NSUInteger)theMessage {
    NSUInteger status = statusOrdinal;
    CDVPluginResult *pluginResult = [self resultWithStatus:status messageAsUnsignedInteger:theMessage];
    return pluginResult;
}

- (void)setKeepCallbackAsBool:(BOOL)bKeepCallback {
    self.keepCallback = bKeepCallback;
}

static BOOL gIsVerbose = NO;
+ (void)setVerbose:(BOOL)verbose {
    gIsVerbose = verbose;
}
+ (BOOL)isVerbose {
    return gIsVerbose;
}

@end
