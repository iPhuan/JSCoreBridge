//
//  CDVInvokedUrlCommand.h
//  JSCCordova
//
//  Created by iPhuan on 2017/2/19.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "JSCInvokedPluginCommand.h"

typedef JSCInvokedPluginCommand CDVInvokedUrlCommand;

@interface JSCInvokedPluginCommand (CDVInvokedUrlCommand)

// Returns the argument at the given index.
// If index >= the number of arguments, returns nil.
// If the argument at the given index is NSNull, returns nil.
- (id)argumentAtIndex:(NSUInteger)index;
// Same as above, but returns defaultValue instead of nil.
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue;
// Same as above, but returns defaultValue instead of nil, and if the argument is not of the expected class, returns defaultValue
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass;

@end
