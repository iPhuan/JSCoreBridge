//
//  JSCWebViewController.h
//  JSCoreBridge
//
//  Created by iPhuan on 2016/11/29.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSCAvailability.h"
#import "JSCPluginResult.h"
#import "JSCBridgeDelegate.h"
#import "JSCInvokedPluginCommand.h"

@class JSCPlugin;

NS_ASSUME_NONNULL_BEGIN

@interface JSCWebViewController : UIViewController

@property (nonatomic, readonly, strong) UIWebView *webView;
@property (nonatomic, readonly, weak) id <JSCBridgeDelegate> bridgeDelegate; //use this property to call 'JSCBridgeDelegate' methods

/* To learn how to configure 'config.xml', see:
 http://cordova.apache.org/docs/en/latest/config_ref/index.html 
 
 These options are not implemented by JSCoreBridge:
 1.content
 2.access
 3.engine
 4.plugin
 5.variable
 6.preference('BackupWebStorage', 'TopActivityIndicator', 'ErrorUrl', 'OverrideUserAgent', 'AppendUserAgent', 'target-device', 'deployment-target', 'CordovaWebViewEngine', 'SuppressesLongPressGesture', and 'Suppresses3DTouchGesture')
 
 These options no longer need to be added:
 1.widget('id', 'version', 'defaultlocale', 'ios-CFBundleVersion', 'xmlns', and 'xmlns:cdv')
 2.name
 3.description
 4.author
 */
@property (nonatomic, copy, nullable) NSString *configFilePath; // set a custom 'config.xml' file path; default is nil, use the config file in Bundle
@property (nonatomic, assign, getter=isConfigEnabled) BOOL configEnabled; // set NO if you don't want to use 'config.xml'; default is YES
@property (nonatomic, assign) BOOL shouldAutoLoadURL; // set NO if you want to call the loading method manually; default is YES
@property (nonatomic, readonly, assign) CGFloat fitContentTop; // a suggested top for content view, Keep the content view and navigation bottom aligned. You can get a correct value in 'viewDidLoad'
@property (nonatomic, readonly, assign) CGFloat fitContentHeight; // a suggested height for content view



- (instancetype)initWithUrl:(NSString *)url;

- (void)loadURL:(NSURL *)URL;
- (void)loadHTMLString:(NSString *)htmlString;


// override these methods if you need to do something when webView load
- (BOOL)jsCoreBridgeWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)jsCoreBridgeWebViewDidStartLoad:(UIWebView *)webView;
- (void)jsCoreBridgeWebViewDidFinishLoad:(UIWebView *)webView;
- (void)jsCoreBridgeWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;


// override these methods if you need to do something when jsCoreBridge call 'deviceready'
- (void)jsCoreBridgeWillReady:(UIWebView *)webView;
- (void)jsCoreBridgeDidReady:(UIWebView *)webView;

@end

NS_ASSUME_NONNULL_END

