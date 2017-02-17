//
//  JSCPrint.m
//  JSCoreBridge
//
//  Created by iPhuan on 2016/12/5.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSCPrint.h"
#import "JSCAvailability.h"
#import "JSCDebug.h"


@implementation JSCPrint

#pragma mark - Print

+ (void)print{
    [self p_printVersion];
    [self p_printJSMinRequiredVersion];
    [self p_printPlatformVersionWarning];
    [self p_printMultitaskingInfo];
}

+ (void)p_printVersion{
    JSCLog(@"JSCoreBridge native platform version %@ is starting.", JSC_VERSION);
}

+ (void)p_printJSMinRequiredVersion{
    JSCLog(@"'jsCoreBridge.js' minimum required version %@.", JSCOREBRIDGE_JS_VERSION_MIN_REQUIRED);
}

+ (void)p_printPlatformVersionWarning{
    if (!IsAtLeastiOSVersion(@"8.0")) {
        JSCLog(@"CRITICAL: For JSCoreBridge %@ and above, you will need to upgrade to at least iOS 8.0 or greater. Your current version of iOS is %@.",JSC_VERSION, [[UIDevice currentDevice] systemVersion]);
    }
}

+ (void)p_printMultitaskingInfo{
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = device.isMultitaskingSupported;
    
    NSNumber* exitsOnSuspend = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIApplicationExitsOnSuspend"];
    if (exitsOnSuspend == nil) { // if it's missing, it should be NO (i.e. multi-tasking on by default)
        exitsOnSuspend = [NSNumber numberWithBool:NO];
    }
    
    JSCLog(@"Multi-tasking -> Device: %@, App: %@", (backgroundSupported ? @"YES" : @"NO"), (![exitsOnSuspend intValue]) ? @"YES" : @"NO");
}

@end
