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

#import "JSCConfigParser.h"
#import "JSCDebug.h"


@interface JSCConfigParser () {
    NSString *_featureName;
}

@property (nonatomic, readwrite, strong) NSMutableDictionary *pluginsDict;
@property (nonatomic, readwrite, strong) NSMutableDictionary *settings;
@property (nonatomic, readwrite, strong) NSMutableArray *startupPluginNames;
@property (nonatomic, readwrite, strong) NSMutableArray* allowIntents;
@property (nonatomic, readwrite, strong) NSMutableArray* allowNavigations;
@property (nonatomic, readwrite, strong) NSString *startPage;
@property (nonatomic, readwrite, assign) BOOL parserSuccess;

@end

@implementation JSCConfigParser

- (id)init{
    self = [super init];
    if (self) {
        _pluginsDict = [[NSMutableDictionary alloc] initWithCapacity:30];
        _settings = [[NSMutableDictionary alloc] initWithCapacity:30];
        _startupPluginNames = [[NSMutableArray alloc] initWithCapacity:8];
        
        // file: url <allow-navigations> are added by default
        _allowNavigations = [[NSMutableArray alloc] initWithArray:@[ @"file://" ]];
        // no intents are added by default
        _allowIntents = [[NSMutableArray alloc] init];
        _featureName = nil;
        _parserSuccess = NO;
    }
    return self;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName attributes:(NSDictionary*)attributeDict{
    if ([elementName isEqualToString:@"preference"]) {
        _settings[[attributeDict[@"name"] lowercaseString]] = attributeDict[@"value"];
    } else if ([elementName isEqualToString:@"feature"]) { // store feature name to use with correct parameter set
        _featureName = [attributeDict[@"name"] lowercaseString];
    } else if ((_featureName != nil) && [elementName isEqualToString:@"param"]) {
        NSString* paramName = [attributeDict[@"name"] lowercaseString];
        id value = attributeDict[@"value"];
        if ([paramName isEqualToString:@"ios-package"]) {
            _pluginsDict[_featureName] = value;
        }
        BOOL paramIsOnload = ([paramName isEqualToString:@"onload"] && [@"true" isEqualToString : value]);
        BOOL attribIsOnload = [@"true" isEqualToString :[attributeDict[@"onload"] lowercaseString]];
        if (paramIsOnload || attribIsOnload) {
            [_startupPluginNames addObject:_featureName];
        }
    } else if ([elementName isEqualToString:@"content"]) {
        self.startPage = attributeDict[@"src"];
    } else if ([elementName isEqualToString:@"allow-navigation"]) {
        [_allowNavigations addObject:attributeDict[@"href"]];
    } else if ([elementName isEqualToString:@"allow-intent"]) {
        [_allowIntents addObject:attributeDict[@"href"]];
    }
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName{
    self.parserSuccess = YES;
    if ([elementName isEqualToString:@"feature"]) { // no longer handling a feature so release
        _featureName = nil;
    }
}

- (void)parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError{
    self.parserSuccess = NO;
    JSCLog(@"config.xml parse error line %ld col %ld. 'config.xml' will not be used", (long)[parser lineNumber], (long)[parser columnNumber]);
}

@end
