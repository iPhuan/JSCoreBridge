//
//  JSCBridgeDelegateImpl.m
//  JSCoreBridge
//
//  Created by iPhuan on 2017/1/9.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "JSCBridgeDelegateImpl.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSCDebug.h"
#import "JSCBridge.h"
#import "JSCPluginResult.h"


NSString *const kJSCCallbackNoneMark = @"INVALID";


@interface JSCBridgeDelegateImpl ()
@property (nonatomic, weak) JSCBridge *bridge;
@property (nonatomic, strong) NSRegularExpression *callbackIdPattern;;


@end


@implementation JSCBridgeDelegateImpl

- (instancetype)initWithBridge:(JSCBridge *)bridge{
    self = [super init];
    if (self) {
        _bridge = bridge;
        
        NSError* err = nil;
        _callbackIdPattern = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9._-]" options:0 error:&err];
        if (err != nil) {
            // Couldn't initialize Regex
            JSCLog(@"Error: Couldn't initialize regex");
            _callbackIdPattern = nil;
        }

    }
    return self;
}

#pragma mark - JSCPlugin

- (void)registerPlugin:(JSCPlugin *)plugin withPluginName:(NSString *)pluginName {
    [_bridge registerPlugin:plugin withPluginName:pluginName];
}

- (JSCPlugin *)getPluginInstance:(NSString *)pluginName {
    return [_bridge getPluginInstance:pluginName];
}

#pragma mark - EvaluateScript

- (void)sendPluginResult:(JSCPluginResult *)result forCallbackId:(NSString *)callbackId{
    if (result == nil) {
        JSCLog(@"JSCPluginResult can not be nil");
        return;
    }
    
    // This occurs when there is are no success/fail callbacks for the call.
    if ([kJSCCallbackNoneMark isEqualToString:callbackId]) {
        return;
    }
    
    // This occurs when the callback id is malformed.
    if (![self p_isValidCallbackId:callbackId]) {
        JSCLog(@"Invalid callback id received by sendPluginResult");
        return;
    }
    
    JSC_EXEC_LOG(@"Exec(%@): Sending result (message=%@, Status=%lu)", callbackId, result.message, (unsigned long)result.status);
    NSArray *arguments = @[callbackId, @(result.status), result.message, @(result.isKeepCallback)];
    
    [self onMainThreadCallScriptFunction:@"jsCoreBridge.nativeCallback" withArguments:arguments];
}



- (BOOL)p_isValidCallbackId:(NSString*)callbackId{
    if (!callbackId || !_callbackIdPattern) {
        return NO;
    }
    
    // Disallow if too long or if any invalid characters were found.
    if (([callbackId length] > 100) || [_callbackIdPattern firstMatchInString:callbackId options:0 range:NSMakeRange(0, [callbackId length])]) {
        return NO;
    }
    return YES;
}

- (JSValue *)evaluateScript:(NSString *)script{
    return [_bridge.context evaluateScript:script];
}

- (JSValue *)callScriptFunction:(NSString *)funcName withArguments:(NSArray *)arguments{
    if (funcName == nil) {
        return nil;
    }
    
    JSValue *funcValue= nil;
    if ([funcName containsString:@"."]) {
        funcValue = [_bridge.context evaluateScript:funcName];
    }else{
        funcValue = _bridge.context[funcName];
    }
    return [funcValue callWithArguments:arguments];
}

- (void)onMainThreadEvaluateScript:(NSString *)script{
    if ([NSThread isMainThread]) {
        [self evaluateScript:script];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self evaluateScript:script];
        });
    }
}

- (void)onMainThreadCallScriptFunction:(NSString *)funcName withArguments:(NSArray *)arguments{
    if ([NSThread isMainThread]) {
        [self callScriptFunction:funcName withArguments:arguments];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self callScriptFunction:funcName withArguments:arguments];
        });
    }
}


#pragma mark - Other

- (void)runInBackground:(void (^)())block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

- (void)runOnMainThread:(void (^)())block{
    if ([NSThread isMainThread]) {
        block();
    }else{
        dispatch_async(dispatch_get_main_queue(), block);
    }
}




@end
