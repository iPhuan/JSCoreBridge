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

#import "JSCPluginResult.h"
#import "JSCDebug.h"


@interface JSCPluginResult ()

@property (nonatomic, readwrite, strong) id message;
@property (nonatomic, readwrite, assign) JSCCommandStatus status;

@end

@implementation JSCPluginResult


#pragma mark - For asynchronous plugin method

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status{
    return [[self alloc] initWithStatus:status message:nil];
}

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsString:(NSString*)message{
    return [[self alloc] initWithStatus:status message:message];
}

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsArray:(NSArray*)messages{
    return [[self alloc] initWithStatus:status message:messages];
}

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsInt:(int)message{
    return [[self alloc] initWithStatus:status message:@(message)];
}

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsInteger:(NSInteger)message{
    return [[self alloc] initWithStatus:status message:@(message)];
}

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsUnsignedInteger:(NSUInteger)message{
    return [[self alloc] initWithStatus:status message:@(message)];
}

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsDouble:(double)message{
    return [[self alloc] initWithStatus:status message:@(message)];
}

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsBool:(BOOL)message{
    return [[self alloc] initWithStatus:status message:@(message)];
}

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsDictionary:(NSDictionary*)message{
    return [[self alloc] initWithStatus:status message:message];
}

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsArrayBuffer:(NSData*)message{
    return [[self alloc] initWithStatus:status message:p_messageFromArrayBuffer(message)];
}

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageAsMultipart:(NSArray*)messages{
    return [[self alloc] initWithStatus:status message:p_messageFromMultipart(messages)];
}

+ (JSCPluginResult *)resultWithStatus:(JSCCommandStatus)status messageToErrorObject:(int)errorCode{
    return [[self alloc] initWithStatus:status message:[self messageToErrorObject:errorCode]];
}

- (JSCPluginResult *)initWithStatus:(JSCCommandStatus)status message:(id)message{
    self = [super init];
    if (self) {
        _status = status;
        _message = message;
        _keepCallback = NO;
    }
    return self;
}


#pragma mark - For synchronous plugin method

+ (NSDictionary *)messageAsArrayBuffer:(NSData*)message{
    return p_messageFromArrayBuffer(message);
}

+ (NSDictionary *)messageAsMultipart:(NSArray*)messages{
    return p_messageFromMultipart(messages);
}

+ (NSDictionary *)messageToErrorObject:(int)errorCode{
    return @{@"code" :@(errorCode)};
}


#pragma mark - Private

id p_messageFromArrayBuffer(NSData* data){
    return @{@"CDVType" : @"ArrayBuffer",
             @"data" :[data base64EncodedStringWithOptions:0]};
}

id p_messageFromMultipart(NSArray* arrayMessage) {
    NSMutableArray* messages = [[NSMutableArray alloc] initWithArray:arrayMessage];
    [messages enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        [messages replaceObjectAtIndex:index withObject:p_massageMessage(object)];
    }];
    
    return @{@"CDVType" : @"MultiPart",
             @"messages" : messages};
}

id p_massageMessage(id message){
    if ([message isKindOfClass:[NSData class]]) {
        return p_messageFromArrayBuffer(message);
    }
    return message;
}

@end
