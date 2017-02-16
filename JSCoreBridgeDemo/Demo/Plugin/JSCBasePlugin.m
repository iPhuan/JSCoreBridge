//
//  JSCBasePlugin.m
//  JSCoreBridgeDemo
//
//  Created by iPhuan on 2017/2/14.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "JSCBasePlugin.h"

@interface JSCBasePlugin (){
    NSMutableDictionary *_KeepCallbackDic;
}

@end

// 可以将插件的一些常用方法封装到JSCBasePlugin，供其子类插件使用，比如参数的检查，结果的发送
@implementation JSCBasePlugin

// 可以控制统一入口
- (BOOL)canCallPlugin{
    return YES;
}



#pragma mark - Public

- (void)setKeepCallbackAsBool:(BOOL)isKeepCallback forcallbackId:(NSString*)callbackId{
    if (callbackId == nil || [@"" isEqualToString:callbackId]) {
        return;
    }
    
    if (!_KeepCallbackDic) {
        _KeepCallbackDic = [[NSMutableDictionary alloc] init];
    }
    
    [_KeepCallbackDic setObject:[NSNumber numberWithBool:isKeepCallback] forKey:callbackId];
}

#pragma mark - Parameter check
// 这里只是写了一个示例，正常来说，应当有对应不同类型参数的检查方法
- (JSCParamsErrorType)checkRequiredStringParameter:(NSString *)parameterkey inArguments:(NSArray *)arguments{
    if (arguments.count == 0) {
        return JSCParamsErrorTypeNoParameters;
    }
    
    NSDictionary *params = arguments[0];
    
    if (params.count == 0) {
        return JSCParamsErrorTypeNoParameters;
    }
    
    if (parameterkey == nil) {
        return JSCParamsErrorTypeNone;
    }
    
    NSString *parameter = params[parameterkey];
    if (parameter == nil) {
        return JSCParamsErrorTypeRequiredParameterMissing;
    }
    
    if (![parameter isKindOfClass:[NSString class]]) {
        return JSCParamsErrorTypeInvalidFormat;
    }
    
    return JSCParamsErrorTypeNone;
}

- (JSCParamsErrorType)checkRequiredStringParameters:(NSArray *)parameterkeys inArguments:(NSArray *)arguments{
    for (NSString *key in parameterkeys) {
        JSCParamsErrorType errorType = [self checkRequiredStringParameter:key inArguments:arguments];
        if (errorType != JSCParamsErrorTypeNone) {
            return errorType;
        }
    }
    return JSCParamsErrorTypeNone;
}

#pragma mark - Send result

- (void)sendSuccessResultWithMessage:(NSDictionary *)message callbackId:(NSString*)callbackId {
    [self sendPluginResultWithStatus:JSCCommandStatus_OK message:message callbackId:callbackId];
}

- (void)sendSuccessResultWithResCode:(NSString *)resCode resMsg:(NSString *)resMsg callBackId:(NSString *)callbackId{
    NSDictionary *message = @{JSC_KEY_RESCODE:resCode, JSC_KEY_RESMSG:resMsg};
    [self sendPluginResultWithStatus:JSCCommandStatus_OK message:message callbackId:callbackId];
}

- (void)sendFailedResultWithErrorType:(JSCParamsErrorType)errorType callBackId:(NSString *)callbackId {
    switch (errorType) {
        case JSCParamsErrorTypeNone:
            break;
        case JSCParamsErrorTypeNoParameters:
            [self sendFailedResultWithResCode:RESCODE_NO_PARAMETER resMsg:RESMSG_NO_PARAMETER callBackId:callbackId];
            break;
        case JSCParamsErrorTypeInvalidFormat:
            [self sendFailedResultWithResCode:RESCODE_INVALID_PARAMETER_FORMAT resMsg:RESMSG_INVALID_PARAMETER_FORMAT callBackId:callbackId];
            break;
        case JSCParamsErrorTypeRequiredParameterMissing:
            [self sendFailedResultWithResCode:RESCODE_REQUIRED_PARAMETER_MISSING resMsg:RESMSG_REQUIRED_PARAMETER_MISSING callBackId:callbackId];
            break;
    }
}

- (void)sendFailedResultWithResCode:(NSString *)resCode resMsg:(NSString *)resMsg callBackId:(NSString *)callbackId {
    NSDictionary *message = @{JSC_KEY_RESCODE:resCode, JSC_KEY_RESMSG:resMsg};
    [self sendPluginResultWithStatus:JSCCommandStatus_ERROR message:message callbackId:callbackId];
}

- (void)sendPluginResultWithStatus:(JSCCommandStatus)commandStatus message:(NSDictionary *)message callbackId:(NSString*)callbackId{
    JSCPluginResult *result = [JSCPluginResult resultWithStatus:commandStatus messageAsDictionary:message];
    //设置是否可以继续回调
    result.keepCallback = [[_KeepCallbackDic objectForKey:callbackId] boolValue];
    [self.bridgeDelegate sendPluginResult:result forCallbackId:callbackId];
}

#pragma mark - Other

- (void)popupAlertViewWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:alertAction];
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover) {
        popover.sourceView = self.webViewController.view;
        popover.sourceRect = self.webViewController.view.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self.webViewController presentViewController:alertController animated:YES completion:nil];
}


@end
