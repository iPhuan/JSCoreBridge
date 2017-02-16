//
//  JSCInvokedPluginCommand.m
//  JSCorePluginDemo
//
//  Created by iPhuan on 2016/11/29.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import "JSCInvokedPluginCommand.h"
#import "JSCDebug.h"


@interface JSCInvokedPluginCommand ()

@property (nonatomic, readwrite, copy) NSString *callbackId;
@property (nonatomic, readwrite, copy) NSString *className;
@property (nonatomic, readwrite, copy) NSString *methodName;
@property (nonatomic, readwrite, strong) NSArray *arguments;


@end

@implementation JSCInvokedPluginCommand

+ (JSCInvokedPluginCommand *)commandFromJSArray:(NSArray *)jsArray {
    if (jsArray.count != 4) {
        JSCLog(@"ERROR: Commands is not correct.");
        return nil;
    }
    
    JSCInvokedPluginCommand *command = [[JSCInvokedPluginCommand alloc] init];
    command.callbackId = jsArray[0];
    command.className = jsArray[1];
    command.methodName = jsArray[2];
    command.arguments = jsArray[3];

    return command;
}

- (NSString *)description{
    NSDictionary *descDic = @{@"callbackId":_callbackId?:@"nil",
                              @"className":_className?:@"nil",
                              @"methodName":_methodName?:@"nil",
                              @"arguments":_arguments?:@"nil"};
    return [NSString stringWithFormat:@"<%@: %p, %@>", [self class], self, descDic];
}

@end
