//
//  JSCConfig.h
//  JSCoreBridge
//
//  Created by iPhuan on 2016/12/5.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface JSCConfig : NSObject
@property (nonatomic, readonly, strong) NSArray *startupPluginNames;
@property (nonatomic, readonly, strong) NSDictionary *pluginsMap;

- (instancetype)initWithPath:(NSString *)path;

- (BOOL)loadConfig;
- (void)setSettingsForWebView:(UIWebView *)webView;
- (BOOL)shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType;


@end
