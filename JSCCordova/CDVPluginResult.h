//
//  CDVPluginResult.h
//  JSCCordova
//
//  Created by iPhuan on 2017/2/19.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "JSCPluginResult.h"


typedef JSCCommandStatus CDVCommandStatus;

extern const NSUInteger CDVCommandStatus_OK;
extern const NSUInteger CDVCommandStatus_ERROR;


@interface CDVPluginResult : JSCPluginResult

// This property can be used to scope the lifetime of another object. For example,
// Use it to store the associated NSData when `message` is created using initWithBytesNoCopy.
@property (nonatomic, strong) id associatedObject;

+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsNSInteger:(NSInteger)theMessage;
+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsNSUInteger:(NSUInteger)theMessage;

- (void)setKeepCallbackAsBool:(BOOL)bKeepCallback;

+ (void)setVerbose:(BOOL)verbose;
+ (BOOL)isVerbose;
@end
