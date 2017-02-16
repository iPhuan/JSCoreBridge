//
//  UIWebView+JSCJavaScriptContext.m
//
//  Modified from UIWebView+TS_JavaScriptContext by iPhuan on 12/26/16.
//  Copyright (c) 2013 CoDeveloper, LLC. All rights reserved.
//

#import "UIWebView+JSCJavaScriptContext.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>

static const char kJSCJavaScriptContext[] = "JSCJavaScriptContext";
static NSHashTable* jscWebViews = nil;


@interface UIWebView (JSCJavaScriptCore_private)
- (void) jscWebViewDidCreateJavaScriptContext:(JSContext *)context;

@end


@protocol JSCWebFrame <NSObject>
- (id)parentFrame;

@end

@implementation NSObject (JSCJavaScriptContext)

- (void)webView:(id)unused didCreateJavaScriptContext:(JSContext *)ctx forFrame:(id<JSCWebFrame>)frame {
    BOOL canCallParentFrame = [frame respondsToSelector:@selector(parentFrame)];
    
    NSParameterAssert(canCallParentFrame);
    
    // only interested in root-level frames
    if (canCallParentFrame && [frame parentFrame] != nil){
        return;
    }
    
    void (^webViewDidCreateJavaScriptContext)() = ^{
        for ( UIWebView *webView in jscWebViews ){
            NSString *cookie = [NSString stringWithFormat:@"jscWebView_%lud", (unsigned long)webView.hash];
            [webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"var %@ = '%@'", cookie, cookie]];
            
            if ([ctx[cookie].toString isEqualToString:cookie]){
                [webView jscWebViewDidCreateJavaScriptContext:ctx];
                break;
            }
        }
    };
    
    if ([NSThread isMainThread]) {
        webViewDidCreateJavaScriptContext();
    }else {
        dispatch_async( dispatch_get_main_queue(), webViewDidCreateJavaScriptContext);
    }
}

@end


@implementation UIWebView (JSCJavaScriptContext)

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jscWebViews = [NSHashTable weakObjectsHashTable];
    });
    
    NSAssert([NSThread isMainThread], @"WebView must be initialized on the main thread");
    id webView = [super allocWithZone: zone];
    [jscWebViews addObject: webView];
    
    return webView;
}

- (void)jscWebViewDidCreateJavaScriptContext:(JSContext *)context {
    [self willChangeValueForKey: @"jscJavaScriptContext"];
    
    objc_setAssociatedObject(self, kJSCJavaScriptContext, context, OBJC_ASSOCIATION_RETAIN);
    
    [self didChangeValueForKey: @"jscJavaScriptContext"];
    
    if ( [self.delegate respondsToSelector:@selector(jsCoreBridgeWebView:didCreateJavaScriptContext:)] )
    {
        id<JSCWebViewDelegate> delegate = (id<JSCWebViewDelegate>)self.delegate;
        [delegate jsCoreBridgeWebView:self didCreateJavaScriptContext:context];
    }
}

- (JSContext *)jscJavaScriptContext{
    JSContext *context = objc_getAssociatedObject(self, kJSCJavaScriptContext);
    return context;
}

@end
