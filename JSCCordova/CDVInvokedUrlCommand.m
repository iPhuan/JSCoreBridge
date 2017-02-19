//
//  CDVInvokedUrlCommand.m
//  JSCCordova
//
//  Created by iPhuan on 2017/2/19.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "CDVInvokedUrlCommand.h"

@implementation JSCInvokedPluginCommand (CDVInvokedUrlCommand)

- (id)argumentAtIndex:(NSUInteger)index{
    return [self argumentAtIndex:index withDefault:nil];
}

- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue{
    return [self argumentAtIndex:index withDefault:defaultValue andClass:nil];
}

- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass{
    if (index >= [self.arguments count]) {
        return defaultValue;
    }
    id ret = [self.arguments objectAtIndex:index];
    if (ret == [NSNull null]) {
        ret = defaultValue;
    }
    if ((aClass != nil) && ![ret isKindOfClass:aClass]) {
        ret = defaultValue;
    }
    return ret;
}

@end
