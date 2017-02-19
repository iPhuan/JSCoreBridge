/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JSCCommandStatus) {
    JSCCommandStatus_OK = 0,       // call success function
    JSCCommandStatus_ERROR         // call fail function
};

NS_ASSUME_NONNULL_BEGIN

@interface JSCPluginResult : NSObject

@property (nonatomic, readonly, strong) id message;
@property (nonatomic, readonly, assign) JSCCommandStatus status;


@property (nonatomic, assign, getter=isKeepCallback) BOOL keepCallback; // Set YES if you want multiple callbacks; default is NO


// For asynchronous plugin method
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status;
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsString:(NSString*)message;
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsArray:(NSArray*)messages;
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsInt:(int)message;
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsInteger:(NSInteger)message;
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsUnsignedInteger:(NSUInteger)message;
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsDouble:(double)message;
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsBool:(BOOL)message;
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsDictionary:(NSDictionary*)message;
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsArrayBuffer:(NSData*)message;
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsMultipart:(NSArray*)messages;
+ (__kindof JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageToErrorObject:(int)errorCode;


// For synchronous plugin method
+ (NSDictionary *)messageAsArrayBuffer:(NSData*)message;
+ (NSDictionary *)messageAsMultipart:(NSArray*)messages;
+ (NSDictionary *)messageToErrorObject:(int)message;


@end

NS_ASSUME_NONNULL_END

