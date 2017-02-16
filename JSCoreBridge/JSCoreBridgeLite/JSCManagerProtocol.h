//
//  JSCManagerProtocol.h
//  JSCoreBridge
//
//  Created by iPhuan on 2017/1/3.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSCBridge;

NS_ASSUME_NONNULL_BEGIN

@protocol JSCManagerProtocol <NSObject>

@required

- (instancetype)initWithBridge:(JSCBridge *)bridge;

- (BOOL)enableManager;

- (BOOL)shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType;

+ (void)startTimer:(NSString *)name;
+ (void)stopTimer:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
