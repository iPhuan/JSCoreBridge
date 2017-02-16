//
//  JSCDebug.h
//  JSCoreBridge
//
//  Created by iPhuan on 2016/12/4.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#ifdef DEBUG
#define JSCLog(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define JSCLog(xx, ...)  ((void)0)
#endif


// Enable this to log all exec() calls.
#define JSC_ENABLE_EXEC_LOGGING  1


#if JSC_ENABLE_EXEC_LOGGING
#define JSC_EXEC_LOG JSCLog
#else
#define JSC_EXEC_LOG(...) do { \
} while (NO)
#endif





