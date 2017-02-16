//
//  JSCBridgeDelegate.h
//  JSCoreBridge
//
//  Created by iPhuan on 2017/1/9.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import <Foundation/Foundation.h>


@class JSCPlugin;
@class JSCPluginResult;
@class JSValue;

NS_ASSUME_NONNULL_BEGIN

@protocol JSCBridgeDelegate <NSObject>

// Register a plugin add to the pluginsMap
- (void)registerPlugin:(JSCPlugin *)plugin withPluginName:(NSString *)pluginName;

// Returns an instance of a Plugin object, based on its name
- (nullable __kindof JSCPlugin *)getPluginInstance:(NSString *)pluginName;

// Use this to send a result to callbacks
- (void)sendPluginResult:(JSCPluginResult *)result forCallbackId:(NSString *)callbackId;

// Use this to execute script
- (JSValue *)evaluateScript:(NSString *)script;

// Use this to call script function
- (JSValue *)callScriptFunction:(NSString *)funcName withArguments:(nullable NSArray *)arguments;

// Ensure that the JS can be executed in the main thread
- (void)onMainThreadEvaluateScript:(NSString *)script;
- (void)onMainThreadCallScriptFunction:(NSString *)funcName withArguments:(nullable NSArray *)arguments;

// Runs the given block on a background thread using a shared thread-pool.
- (void)runInBackground:(void (^)())block;
- (void)runOnMainThread:(void (^)())block;


@end

NS_ASSUME_NONNULL_END

