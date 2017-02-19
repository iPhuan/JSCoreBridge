//
//  CDVPlugin.m
//  JSCCordova
//
//  Created by iPhuan on 2017/2/19.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "CDVPlugin.h"

@implementation CDVPlugin

- (JSCWebViewController *)viewController{
    return self.webViewController;
}

- (id)commandDelegate{
    return self.bridgeDelegate;
}

- (void)pluginDidInitialize{
    [self pluginInitialize];
}

- (void)pluginInitialize {
}

@end
