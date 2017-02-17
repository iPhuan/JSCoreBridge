/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "JSCTimer.h"
#import "JSCDebug.h"


#pragma mark JSCTimerItem

@interface JSCTimerItem : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *started;
@property (nonatomic, strong) NSDate *ended;

- (void)log;

@end

@implementation JSCTimerItem

- (void)log{
    JSCLog(@"[JSCTimer][%@] %fms", _name, [_ended timeIntervalSinceDate:_started] * 1000.0);
}

@end

#pragma mark JSCTimer

@interface JSCTimer ()

@property (nonatomic, strong) NSMutableDictionary *items;

@end

@implementation JSCTimer

#pragma mark object methods

- (id)init{
    if (self = [super init]) {
        _items = [NSMutableDictionary dictionaryWithCapacity:6];
    }

    return self;
}

- (void)add:(NSString *)name{
    if (!_items[name.lowercaseString]) {
        JSCTimerItem *item = [JSCTimerItem new];
        item.name = name;
        item.started = [NSDate new];
        _items[name.lowercaseString] = item;
    } else {
        JSCLog(@"Timer called '%@' already exists.", name);
    }
}

- (void)remove:(NSString *)name{
    JSCTimerItem* item = _items[name.lowercaseString];

    if (item) {
        item.ended = [NSDate new];
        [item log];
        [_items removeObjectForKey:name.lowercaseString];
    } else {
        JSCLog(@"Timer called '%@' does not exist.", name);
    }
}

- (void)removeAll{
    [_items removeAllObjects];
}

#pragma mark class methods

+ (void)start:(NSString *)name{
#ifdef DEBUG
    if (name == nil) {
        JSCLog(@"Can't start With nil");
        return;
    }
    [[JSCTimer sharedInstance] add:name];
#endif
}

+ (void)stop:(NSString *)name{
#ifdef DEBUG
    if (name == nil) {
        JSCLog(@"Can't stop With nil");
        return;
    }
    [[JSCTimer sharedInstance] remove:name];
#endif
}

+ (void)clearAll
{
#ifdef DEBUG
    [[JSCTimer sharedInstance] removeAll];
#endif
}

+ (JSCTimer *)sharedInstance{
    static dispatch_once_t pred = 0;
    __strong static JSCTimer* _sharedTimer = nil;

    dispatch_once(&pred, ^{
            _sharedTimer = [[self alloc] init];
        });

    return _sharedTimer;
}

@end
