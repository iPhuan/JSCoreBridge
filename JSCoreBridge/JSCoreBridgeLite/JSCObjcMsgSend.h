//
//  JSCObjcMsgSend.h
//  JSCoreBridge
//
//  Created by iPhuan on 2016/12/15.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

static void (* _Nullable jsc_msgSend)(id, SEL, id _Nullable, ...) = (void (*)(id, SEL, id, ...))objc_msgSend;

static id _Nullable(* _Nullable jsc_id_msgSend)(id, SEL, id _Nullable, ...) = (id (*)(id, SEL, id, ...))objc_msgSend;

static BOOL(*jsc_bool_msgSend)(id, SEL, id _Nullable, ...) = (BOOL (*)(id, SEL, id, ...))objc_msgSend;

/*
 Method return type  |  jsc_objc_msgSend return type
 --------------------+-------------------------------
        void         |         nil
          id         |         id
        BOOL         |         NSNumber
       other         |         NSValue
 */
id _Nullable jsc_objc_msgSend_0(id target, NSString *selectorName);
id _Nullable jsc_objc_msgSend_1(id target, NSString *selectorName, id _Nullable object);
id _Nullable jsc_objc_msgSend_2(id target, NSString *selectorName, id _Nullable object1, id _Nullable object2);

NS_ASSUME_NONNULL_END
