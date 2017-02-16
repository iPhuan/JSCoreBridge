//
//  JSCInvokedPluginCommand.h
//  JSCorePluginDemo
//
//  Created by iPhuan on 2016/11/29.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSCInvokedPluginCommand : NSObject

@property (nonatomic, readonly, copy) NSString *callbackId;
@property (nonatomic, readonly, copy) NSString *className;
@property (nonatomic, readonly, copy) NSString *methodName;
@property (nonatomic, readonly, strong) NSArray *arguments;


+ (JSCInvokedPluginCommand *)commandFromJSArray:(NSArray *)jsArray;

@end

NS_ASSUME_NONNULL_END
