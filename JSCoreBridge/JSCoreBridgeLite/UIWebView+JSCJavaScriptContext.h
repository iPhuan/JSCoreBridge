//
//  UIWebView+JSCJavaScriptContext.h
//  JSCoreBridge
//
//  Modified from UIWebView+TS_JavaScriptContext by iPhuan on 12/26/16.
//  Copyright (c) 2013 CoDeveloper, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSContext;

@protocol JSCWebViewDelegate <UIWebViewDelegate>

@optional

- (void)jsCoreBridgeWebView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)context;

@end


@interface UIWebView (JSCJavaScriptContext)

@property (nonatomic, weak, readonly) JSContext *jscJavaScriptContext;

@end
