//
//  JSCTestPlugin.m
//  JSCoreBridgeDemo
//
//  Created by iPhuan on 2017/2/12.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "JSCTestPlugin.h"
#import <MessageUI/MessageUI.h>


@interface JSCTestPlugin ()<MFMailComposeViewControllerDelegate>

@end

@implementation JSCTestPlugin

#pragma mark - JSCInvokedPluginCommand

// 简单例子，一般用法
- (void)changeNavTitle:(JSCInvokedPluginCommand *)command {
    BOOL isSuccess = NO;
    // 为了避免Web参数传递有问题，保险起见先对参数做检查
    if (command.arguments.count > 0) {
        // 获取参数
        NSDictionary *params = command.arguments[0];
        NSString *title = params[@"title"];
        
        // 假设title为必须参数
        if (title && [title isKindOfClass:[NSString class]]) {
            self.webViewController.title = title;
            isSuccess = YES;
        }
    }
    
    // JSCCommandStatus_OK回调成功函数
    JSCCommandStatus status = JSCCommandStatus_OK;
    NSDictionary *message = @{JSC_KEY_RESCODE:@"0", JSC_KEY_RESMSG:@"OK"};
    if (!isSuccess) {
        // JSCCommandStatus_ERROR回调失败函数
        status = JSCCommandStatus_ERROR;
        message = @{JSC_KEY_RESCODE:@"404", JSC_KEY_RESMSG:@"error parameters"};
    }

    // 将要返回给Web的结果以字典形式通过JSCPluginResult初始化
    JSCPluginResult *result = [JSCPluginResult resultWithStatus:status messageAsDictionary:message];
    // 发送结果
    [self.bridgeDelegate sendPluginResult:result forCallbackId:command.callbackId];
}


// 使用基类JSCBasePlugin对应方法进行参数检查和结果发送
- (void)sendEmail:(JSCInvokedPluginCommand *)command {
    // 假设title和content为必须参数
    JSCParamsErrorType errorType = [self checkRequiredStringParameters:@[@"title", @"content"] inArguments:command.arguments];
    if (errorType != JSCParamsErrorTypeNone) {
        [self sendFailedResultWithErrorType:errorType callBackId:command.callbackId];
        return;
    }

    // 获取参数
    NSDictionary *params = command.arguments[0];
    NSString *title = params[@"title"];
    NSString *content = params[@"content"];
    
    // 保存callbackId，以便之后在代理中回调；该用法只适用于当前插件只有一个插件方法需要用到backupCallbackId，如果多个插件方法需要保存callbackId，建议参考cordova官方插件的一些写法，将callbackId作为其对应使用对象的属性成员，如CDVCamera插件，CDVCameraPicker继承UIImagePickerController，并拥有callbackId属性 https://github.com/apache/cordova-plugin-camera/blob/master/src/ios/CDVCamera.h
    self.backupCallbackId = command.callbackId;
    [self p_sendEmailWithTitle:title content:content];
}


// 同步操作获取应用版本号
- (NSString *)getAppVersionSync:(JSCInvokedPluginCommand *)command {
    // 同步操作，线程在子线程上，如果有UI操作，应当把操作放在主线程上操作
    // 使用runOnMainThread保证在主线程上执行，更多API可参考JSCBridgeDelegate
    [self.bridgeDelegate runOnMainThread:^{
        [self p_showTestMaskView];
    }];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    // 目前只支持返回object类型
    return appVersion;
}


#pragma mark - Private

- (void)p_sendEmailWithTitle:(NSString *)title content:(NSString *)content {
    if (![MFMailComposeViewController canSendMail]) {
        [self popupAlertViewWithTitle:@"无法发送邮件" message:@"您还未设置过邮箱账户，请先在设置中设置邮箱后再使用邮件功能。"];
        // 使用backupCallbackId
        [self sendFailedResultWithResCode:RESCODE_FAIL resMsg:RESMSG_FAIL callBackId:self.backupCallbackId];
        return;
    }
    
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self;
    [mailComposeViewController setSubject:title];
    [mailComposeViewController setMessageBody:content isHTML:NO];
    [self.webViewController presentViewController:mailComposeViewController animated:YES completion:nil];
    
    // 实际设置JSCPluginResult的keepCallback属性为YES, 保持插件能够通过同一callbackId多次回调
    [self setKeepCallbackAsBool:YES forcallbackId:self.backupCallbackId];
    // 第一次回调结果，通知操作成功
    [self sendSuccessResultWithResCode:RESCODE_SUCCESS resMsg:RESMSG_SUCCESS callBackId:self.backupCallbackId];
}


- (void)p_showTestMaskView{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    
    // 使用webViewController的fitContentTop和fitContentHeight来适配对应视图的显示
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, self.webViewController.fitContentTop, width, self.webViewController.fitContentHeight)];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.8;
    [self.webViewController.view addSubview:maskView];
    [UIView animateWithDuration:0.6f animations:^{
        maskView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [maskView removeFromSuperview];
        }
    }];
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
    // 使用backupCallbackId再次回调，发送结果
    [self sendSuccessResultWithMessage:@{@"mailComposeResult":@(result)} callbackId:self.backupCallbackId];
}


#pragma mark - Override

- (void)pluginDidInitialize{
    // Do someting you need after plugin init
    
    // You can listen to more app notifications, see:
    
    // 插件初始化的时候会回调该函数，可以在此进行一些初始化的操作，比如再添加额外的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPause) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (BOOL)canCallPlugin{
    // Override this if you need to forbid call plugin
    
    // 可以在此添加条件来阻止web调用插件，比如只在10.0及以上系统可以调用
    if (IsAtLeastiOSVersion(@"10.0")) {
        return YES;
    }
    return NO;
}


- (void)onMemoryWarning{
    // Override to remove caches, etc
    // 可以在此清理相应缓存，但是不需要清理NSURLCache [[NSURLCache sharedURLCache] removeAllCachedResponses]，JSCoreBridge已做清理

}

- (void)onAppTerminate{
    // Override this if you need to do any cleanup on app exit
}


- (void)onPause{
    
}

- (void)onResume{
    
}


@end
