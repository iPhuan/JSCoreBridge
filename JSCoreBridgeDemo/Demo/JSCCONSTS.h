//
//  JSCCONSTS.h
//  JSCoreBridgeDemo
//
//  Created by iPhuan on 2017/2/13.
//  Copyright © 2017年 iPhuan. All rights reserved.
//


// 通过在pch中提前定义以下几个字段和值，来自定义JSCoreBridge的错误信息，JSCoreBridge在以下几种错误的情况下会以一个字典将code和message返回给Web
#define JSC_KEY_RESCODE @"errCode"
#define JSC_KEY_RESMSG @"errMsg"

#define JSC_RESCODE_PLUGIN_NOT_FOUND @"401"
#define JSC_RESCODE_PLUGIN_CANNOT_CALL @"402"
#define JSC_RESCODE_METHOD_NOT_DEFINED @"403"

#define JSC_RESMSG_PLUGIN_NOT_FOUND  @"ERROR: Plugin not found, or is not a JSCPlugin. Check your plugin mapping in config.xml."
#define JSC_RESMSG_PLUGIN_CANNOT_CALL  @"ERROR: Plugin can not be called, it is not allowed."
#define JSC_RESMSG_METHOD_NOT_DEFINED  @"ERROR: Method not defined in Plugin."



// 错误码和错误信息，通过定义对应的code web可做出相应的处理
#define RESCODE_SUCCESS                         @"1"
#define RESCODE_FAIL                            @"0"

#define RESCODE_NO_PARAMETER                    @"405"
#define RESCODE_INVALID_PARAMETER_FORMAT        @"406"
#define RESCODE_REQUIRED_PARAMETER_MISSING      @"407"


#define RESMSG_SUCCESS                          @"OK"
#define RESMSG_FAIL                             @"fail"

#define RESMSG_NO_PARAMETER                     @"No parameters"
#define RESMSG_INVALID_PARAMETER_FORMAT         @"Invalid parameter format"
#define RESMSG_REQUIRED_PARAMETER_MISSING       @"Required parameter missing"






