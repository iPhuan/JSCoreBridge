//
//  JSCBridge.m
//  JSCoreBridge
//
//  Created by iPhuan on 2016/12/1.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import "JSCBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSCDebug.h"
#import "JSCPlugin.h"
#import "JSCManagerProtocol.h"
#import "JSCObjcMsgSend.h"
#import "JSCBridgeDelegateImpl.h"



NSString *const kJSCExecuteCommandSyncMark = @"EXECSYNC";

@interface JSCBridge ()

@property (nonatomic, readwrite, strong) JSContext *context;
@property (nonatomic, readwrite, strong) id <JSCBridgeDelegate> bridgeDelegate;
@property (nonatomic, weak) JSCWebViewController *webViewController;
@property (nonatomic, strong) id <JSCManagerProtocol> manager;
@property (nonatomic, strong) NSMutableDictionary *pluginObjects;
@property (nonatomic, strong) NSDictionary *pluginsMap;
@property (nonatomic, strong) NSArray *supportedOrientations;
@property (nonatomic, copy) NSString *jsContextKeyPath;


@end

@implementation JSCBridge

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Init

- (instancetype)initWithWebViewController:(JSCWebViewController *)webViewController{
    self = [super init];
    if (self) {
        [self p_setSharedURLCache];
        _webViewController = webViewController;
        
        // Initialize the plugin objects dict.
        _pluginObjects = [[NSMutableDictionary alloc] initWithCapacity:20];
        
        _bridgeDelegate = [[JSCBridgeDelegateImpl alloc] initWithBridge:self];
        
        // read from UISupportedInterfaceOrientations (or UISupportedInterfaceOrientations~iPad, if its iPad) from -Info.plist
        self.supportedOrientations = [self p_parseInterfaceOrientations:
                                      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_onAppWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_onAppDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_memoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_onAppWillResignActive:)
//                                                     name:UIApplicationWillResignActiveNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_onAppDidBecomeActive:)
//                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_onAppWillTerminate:)
//                                                     name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}


- (void)p_setSharedURLCache{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        
        int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
        int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
        NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"NSURLCache"];
        [NSURLCache setSharedURLCache:sharedCache];
    });
}


- (void)webViewControllerViewDidLoad{
    // Initialize JSCManager
    Class managerClass = NSClassFromString(@"JSCManager");
    self.manager = [[managerClass alloc] initWithBridge:self];
    if (_manager == nil) {
        _webViewController.configEnabled = NO;
    }else{
        if (![_manager enableManager]) {
            self.manager = nil;
        }
    }
}


#pragma mark - Get or Set

- (BOOL)isConfigEnabled{
    return _webViewController.isConfigEnabled;
}

- (NSString *)configFilePath{
    return _webViewController.configFilePath;
}

- (UIWebView *)webView{
    return _webViewController.webView;
}

- (void)setPluginsMap:(NSDictionary *)pluginsMap{
    _pluginsMap = pluginsMap;
}

- (NSString *)jsContextKeyPath {
    if (_jsContextKeyPath == nil) {
        NSArray *Keys = @[[@"document" stringByAppendingString:@"View"], @"webView", [@"main" stringByAppendingString:@"Frame"], [@"javaScript" stringByAppendingString:@"Context"]];
        
        _jsContextKeyPath = [Keys componentsJoinedByString:@"."];
    }
    return _jsContextKeyPath;
}


#pragma mark - Orientations

- (BOOL)supportsOrientation:(UIInterfaceOrientation)orientation{
    return [_supportedOrientations containsObject:[NSNumber numberWithInt:orientation]];
}

- (NSArray*)p_parseInterfaceOrientations:(NSArray*)orientations{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    if (orientations != nil) {
        NSEnumerator* enumerator = [orientations objectEnumerator];
        NSString* orientationString;
        
        while (orientationString = [enumerator nextObject]) {
            if ([orientationString isEqualToString:@"UIInterfaceOrientationPortrait"]) {
                [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationPortrait]];
            } else if ([orientationString isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]) {
                [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationPortraitUpsideDown]];
            } else if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
                [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft]];
            } else if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
                [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight]];
            }
        }
    }
    
    // default
    if ([result count] == 0) {
        [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationPortrait]];
    }
    
    return result;
}



#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    BOOL shouldLoad = YES;
        
    if (_webViewController.isConfigEnabled && _manager) {
        shouldLoad = [_manager shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    if (shouldLoad) {
        shouldLoad = [_webViewController jsCoreBridgeWebView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return shouldLoad;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_webViewController jsCoreBridgeWebViewDidStartLoad:webView];
}


// If 'jsCoreBridge.js' is a direct reference, The execution order is as follows:

// 'window.onload' --> 'load' --> 'webViewDidFinishLoad:'('jsCoreBridgeWebViewDidFinishLoad:') --> 'jsCoreBridgeWillReady:' --> 'deviceready' --> 'jsCoreBridgeDidReady:'
/*------------------------------------------------------------------------------------------------------*/

// If 'jsCoreBridge.js' append to document by 'appendChild' or 'insertBefore' JS method, The execution order is as follows:

// 'webViewDidFinishLoad:' --> 'window.onload' --> 'load' --> 'jsCoreBridgeWillReady:' --> 'deviceready' --> 'jsCoreBridgeDidReady:'

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    JSCLog(@"WebView loaded");
    
    self.context = [webView valueForKeyPath:self.jsContextKeyPath];
    
    
    if ([self p_fireDeviceReadyEvent]){
        [self p_defineExecuteCommandJSValue];
        
    // If 'jsCoreBridge.js' append to document by 'appendChild' or 'insertBefore' JS method.
    // At this time, 'jsCoreBridge.js' is not loaded.
    }else{
        __weak __typeof(self) weakSelf = self;
        _context[@"jscWindowOnLoad"] = ^{
            JSCLog(@"Window loaded");
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf p_fireDeviceReadyEvent]) {
                    [weakSelf p_defineExecuteCommandJSValue];
                }
            });
        };
        [_context evaluateScript:@"window.addEventListener(\"load\", jscWindowOnLoad, false)"];
    }
    
    [_webViewController jsCoreBridgeWebViewDidFinishLoad:_webViewController.webView];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_webViewController jsCoreBridgeWebView:webView didFailLoadWithError:error];
}


- (BOOL)p_fireDeviceReadyEvent{
    JSValue *jsCoreBridge = [_context evaluateScript:@"jsCoreBridge"];
    
    if ([jsCoreBridge toObject]) {
        JSValue *version = [_context evaluateScript:@"jsCoreBridge.version"];
        NSString *versionStr = [version toString];
        BOOL isJsCoreBridgeAvailable = [versionStr compare:JSCOREBRIDGE_JS_VERSION_MIN_REQUIRED options:NSNumericSearch] != NSOrderedAscending;
        if (isJsCoreBridgeAvailable) {
            [self p_defineJscBridgeReadyCallbackJSValue];
            [self p_fireDocumentEvent:@"deviceready"];
        }else{
            JSCLog(@"CRITICAL: For JSCoreBridge %@, 'jsCoreBridge.js' need to upgrade to at least %@ or greater. Your current version of 'jsCoreBridge.js' is %@.", JSC_VERSION, JSCOREBRIDGE_JS_VERSION_MIN_REQUIRED, versionStr);
        }
        return isJsCoreBridgeAvailable;
    }
    return NO;
}

- (void)p_fireDocumentEvent:(NSString *)eventName{
    JSCLog(@"Fire '%@' event.", eventName);
    [self.bridgeDelegate callScriptFunction:@"jsCoreBridge.fireDocumentEvent" withArguments:@[eventName]];
}

- (void)p_defineJscBridgeReadyCallbackJSValue {
    __weak __typeof(self) weakSelf = self;
    _context[@"jscBridgeWillReady"] = ^{
        JSCLog(@"JSCoreBridge will be ready");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.webViewController jsCoreBridgeWillReady:weakSelf.webViewController.webView];
        });
    };
    
    _context[@"jscBridgeDidReady"] = ^{
        JSCLog(@"JSCoreBridge is ready");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.webViewController jsCoreBridgeDidReady:weakSelf.webViewController.webView];
        });
    };
}

- (void)p_defineExecuteCommandJSValue {
    __weak __typeof(self) weakSelf = self;
    _context[@"jscExecuteCommand"] = ^(NSArray *commands) {
        JSCInvokedPluginCommand *command = [JSCInvokedPluginCommand commandFromJSArray:commands];
        JSC_EXEC_LOG(@"Received comands:%@", command);
        
        id result;
        if ([kJSCExecuteCommandSyncMark isEqualToString:command.callbackId]) {
            result = [weakSelf p_executeCommand:command];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf p_executeCommand:command];
            });
        }
        return result;
    };
    
    _context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception  = exception;
        JSCLog(@"ERROR: JSContext error: %@", exception);
    };
}


#pragma mark - JSCoreBridgeCommands exec

- (id)p_executeCommand:(JSCInvokedPluginCommand *)command{
    if (command.className == nil || command.methodName == nil || command.callbackId == nil) {
        JSCLog(@"ERROR: Classname and/or methodName and/or callbackId not found for command.");
        return nil;
    }
    
    // Fetch an instance of this class
    JSCPlugin *plugin = [self getPluginInstance:command.className];
    
    if (![plugin isKindOfClass:[JSCPlugin class]]) {
        NSString *errMsg = [NSString stringWithFormat:@"ERROR: Plugin '%@' not found, or is not a JSCPlugin. Check your plugin mapping in config.xml.", command.className];
        return [self p_sendErrorResultWithErrCode:JSC_RESCODE_PLUGIN_NOT_FOUND errMsg:errMsg callBackId:command.callbackId];
    }
    
    
    // Find the proper selector to call.
    NSString* methodName = [NSString stringWithFormat:@"%@:", command.methodName];
    SEL selector = NSSelectorFromString(methodName);
    if (![plugin respondsToSelector:selector]) {
        // There's no method to call, so throw an error.
        NSString *errMsg = [NSString stringWithFormat:@"ERROR: Method '%@' not defined in Plugin '%@'.", methodName, command.className];
        return [self p_sendErrorResultWithErrCode:JSC_RESCODE_METHOD_NOT_DEFINED errMsg:errMsg callBackId:command.callbackId];
    }
    
    if (![plugin canCallPlugin]) {
        // If 'canCallPlugin' return NO, throw an error.
        NSString *errMsg = [NSString stringWithFormat:@"ERROR: Plugin '%@' can not be called, it is not allowed.", command.className];
        return [self p_sendErrorResultWithErrCode:JSC_RESCODE_PLUGIN_CANNOT_CALL errMsg:errMsg callBackId:command.callbackId];
    }
    
    id result = nil;
    BOOL isSync = [kJSCExecuteCommandSyncMark isEqualToString:command.callbackId];
    if (isSync) {
        result = jsc_objc_msgSend_1(plugin, methodName, command);
        if ([result isKindOfClass:[NSValue class]]) {
            JSCLog(@"ERROR: Method '%@' should return an object.", methodName);
            result = nil;
        }
    }else{
        jsc_msgSend(plugin, selector, command);
    }
    return result;
}



- (NSDictionary *)p_sendErrorResultWithErrCode:(NSString *)errCode errMsg:(NSString *)errMsg callBackId:(NSString *)callbackId{
    JSCLog(@"%@", errMsg);
    
    NSString *errMessage = errMsg;
    if ([JSC_RESCODE_PLUGIN_NOT_FOUND isEqualToString:errCode]) {
#ifdef JSC_RESMSG_PLUGIN_NOT_FOUND
        errMessage = JSC_RESMSG_PLUGIN_NOT_FOUND;
#endif
    }else if ([JSC_RESCODE_PLUGIN_CANNOT_CALL isEqualToString:errCode]) {
#ifdef JSC_RESMSG_PLUGIN_CANNOT_CALL
        errMessage = JSC_RESMSG_PLUGIN_CANNOT_CALL;
#endif
    }else if ([JSC_RESCODE_METHOD_NOT_DEFINED isEqualToString:errCode]) {
#ifdef JSC_RESMSG_METHOD_NOT_DEFINED
        errMessage = JSC_RESMSG_METHOD_NOT_DEFINED;
#endif
    }

    NSDictionary *resultDic = @{JSC_KEY_RESCODE:errCode, JSC_KEY_RESMSG:errMessage};
    BOOL isSync = [kJSCExecuteCommandSyncMark isEqualToString:callbackId];
    if (isSync) {
        return resultDic;
    }else{
        JSCPluginResult *result = [JSCPluginResult resultWithStatus:JSCCommandStatus_ERROR messageAsDictionary:resultDic];
        [self.bridgeDelegate sendPluginResult:result forCallbackId:callbackId];
    }
    return nil;
}

/**
 Returns an instance of a Plugin object, based on its name.  If one exists already, it is returned.
 */
- (JSCPlugin *)getPluginInstance:(NSString *)pluginName{
    Class managerClass = NSClassFromString(@"JSCManager");
//    jsc_objc_msgSend_1(managerClass, @"startTimer:", pluginName);
    [managerClass startTimer:pluginName];

    NSString *className = pluginName;

    // first, we try to find the pluginName in the pluginsMap
    // (acts as a whitelist as well) if it does not exist, we return nil
    // NOTE: plugin names are matched as lowercase to avoid problems
    if (_webViewController.isConfigEnabled && _manager) {
        className = _pluginsMap[[pluginName lowercaseString]];
        
        if (className == nil) {
            return nil;
        }
    }
    
    JSCPlugin *plugin = self.pluginObjects[className];
    if (!plugin) {
        Class pluginClass = NSClassFromString(className);
        plugin = [[pluginClass alloc] initWithWebViewController:_webViewController];
        
        if (plugin) {
            [self p_registerPlugin:plugin withClassName:className];
        } else {
            JSCLog(@"JSCPlugin class %@ (pluginName: %@) does not exist.", className, pluginName);
        }
    }
    
    [managerClass stopTimer:pluginName];
//    jsc_objc_msgSend_1(managerClass, @"stopTimer:", pluginName);

    return plugin;
}

- (void)p_registerPlugin:(JSCPlugin *)plugin withClassName:(NSString *)className{
    if (!className) {
        return;
    }
    
    _pluginObjects[className] = plugin;
    [plugin pluginDidInitialize];
}

- (void)registerPlugin:(JSCPlugin *)plugin withPluginName:(NSString *)pluginName{
    if (!pluginName) {
        return;
    }
    
    NSString* className = NSStringFromClass([plugin class]);
    _pluginObjects[className] = plugin;
    [_pluginsMap setValue:pluginName forKey:[pluginName lowercaseString]];
    [plugin pluginDidInitialize];
}

#pragma mark - WebView load

- (void)loadURL:(NSURL *)URL{
    NSURLRequest* request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [_webViewController.webView loadRequest:request];
}

- (void)loadHTMLString:(NSString *)htmlString{
    [_webViewController.webView loadHTMLString:htmlString baseURL:nil];
}


#pragma mark - UIApplicationDelegate Notification

- (void)p_onAppWillEnterForeground:(NSNotification*)notification{
    [self p_fireDocumentEvent:@"resume"];
    
    /** Clipboard fix **/
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    NSString* string = pasteboard.string;
    if (string) {
        [pasteboard setValue:string forPasteboardType:@"public.text"];
    }
}

- (void)p_onAppDidEnterBackground:(NSNotification*)notification{
    [self p_fireDocumentEvent:@"pause"];
}

- (void)p_memoryWarning:(NSNotification*)notification{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


//- (void)p_onAppWillResignActive:(NSNotification*)notification{
//    
//}
//
//- (void)p_onAppDidBecomeActive:(NSNotification*)notification{
//    
//}
//
//- (void)p_onAppWillTerminate:(NSNotification*)notification{
//    
//}



@end
