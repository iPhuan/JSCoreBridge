//
//  JSCBridgeDelegateImpl.h
//  JSCoreBridge
//
//  Created by iPhuan on 2017/1/9.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "JSCBridgeDelegate.h"


@class JSCBridge;

NS_ASSUME_NONNULL_BEGIN

@interface JSCBridgeDelegateImpl : NSObject <JSCBridgeDelegate>

- (instancetype)initWithBridge:(JSCBridge *)bridge;

@end

NS_ASSUME_NONNULL_END


