//
//  CDVPlugin.h
//  JSCCordova
//
//  Created by iPhuan on 2017/2/19.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "JSCPlugin.h"
#import "CDVViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDVPlugin : JSCPlugin
@property (nonatomic, readonly, weak) __kindof JSCWebViewController *viewController;
@property (nonatomic, readonly, weak) id commandDelegate;

- (void)pluginInitialize;

@end

NS_ASSUME_NONNULL_END

