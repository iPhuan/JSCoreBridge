//
//  JSCTestPlugin.h
//  JSCoreBridgeDemo
//
//  Created by iPhuan on 2017/2/12.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "JSCBasePlugin.h"

@interface JSCTestPlugin : JSCBasePlugin

- (void)changeNavTitle:(JSCInvokedPluginCommand *)command;
- (void)sendEmail:(JSCInvokedPluginCommand *)command;
- (NSString *)getAppVersionSync:(JSCInvokedPluginCommand *)command;

@end
