//
//  JSCManager.h
//  JSCoreBridge
//
//  Created by iPhuan on 2016/12/15.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSCManagerProtocol.h"

@interface JSCManager : NSObject <JSCManagerProtocol>

- (instancetype)initWithBridge:(JSCBridge *)bridge;

- (BOOL)enableManager;

- (BOOL)shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType;

+ (void)startTimer:(NSString *)name;
+ (void)stopTimer:(NSString *)name;

@end
