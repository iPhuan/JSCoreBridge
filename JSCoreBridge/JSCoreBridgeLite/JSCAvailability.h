//
//  JSCAvailability.h
//  JSCoreBridge
//
//  Modified from CDVAvailability by iPhuan on 2016/11/30.
//  Copyright © 2016年 iPhuan. All rights reserved.
//


#define __JSCOREBRIDGE_IOS__

/* Version of JSCoreBridge */
#define __JSCOREBRIDGE_0_1_0 100
#define __JSCOREBRIDGE_0_1_1 101
/* coho:next-version,insert-before */
#define __JSCOREBRIDGE_NA 99999      /* not available */

/* Return the string version of the decimal version */
#define JSC_DECIMAL_VERSION(X) [NSString stringWithFormat:@"%d.%d.%d", \
(X / 10000), (X % 10000) / 100, (X % 10000) % 100]

/* Current version of JSCoreBridge */
#define JSCOREBRIDGE_CURRENT_VERSION  __JSCOREBRIDGE_0_1_1
#define JSC_VERSION  JSC_DECIMAL_VERSION(JSCOREBRIDGE_CURRENT_VERSION)


/* Version of JSCoreBridge.js */
#define __JSCOREBRIDGE_JS_0_1_0 100
#define __JSCOREBRIDGE_JS_NA 99999

#define JSCOREBRIDGE_JS_VERSION_MIN_REQUIRED  JSC_DECIMAL_VERSION(__JSCOREBRIDGE_JS_0_1_0)


/*
 Returns YES if it is at least version specified as NSString(X)
 Usage:
 if (IsAtLeastiOSVersion(@"10.2")) {
 // do something for iOS 10.2 or greater
 }
 */
#define IsAtLeastiOSVersion(X) ([[[UIDevice currentDevice] systemVersion] compare:X options:NSNumericSearch] != NSOrderedAscending)


/* Define these keys if you want to custom them */
#ifndef JSC_KEY_RESCODE
#define JSC_KEY_RESCODE @"resCode"
#endif

#ifndef JSC_KEY_RESMSG
#define JSC_KEY_RESMSG @"resMsg"
#endif

/* When the following error occurs，JSCoreBridge will use the define error code and message as a dictionary return to the web. */

/* Define these error code if you want to custom them */
#ifndef JSC_RESCODE_PLUGIN_NOT_FOUND
#define JSC_RESCODE_PLUGIN_NOT_FOUND @"4001"
#endif

#ifndef JSC_RESCODE_PLUGIN_CANNOT_CALL
#define JSC_RESCODE_PLUGIN_CANNOT_CALL @"4002"
#endif

#ifndef JSC_RESCODE_METHOD_NOT_DEFINED
#define JSC_RESCODE_METHOD_NOT_DEFINED @"4003"
#endif


/* Define these error message if you want to custom them */
//#define JSC_RESMSG_PLUGIN_NOT_FOUND  @"ERROR: Plugin not found, or is not a JSCPlugin. Check your plugin mapping in config.xml."
//#define JSC_RESMSG_PLUGIN_CANNOT_CALL  @"ERROR: Plugin can not be called, it is not allowed."
//#define JSC_RESMSG_METHOD_NOT_DEFINED  @"ERROR: Method not defined in Plugin."


#ifdef __clang__
#define JSC_DEPRECATED(version, msg) __attribute__((deprecated("Deprecated in JSCoreBridge " #version ". " msg)))
#else
#define JSC_DEPRECATED(version, msg) __attribute__((deprecated()))
#endif

