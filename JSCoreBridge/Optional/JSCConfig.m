//
//  JSCConfig.m
//  JSCoreBridge
//
//  Created by iPhuan on 2016/12/5.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import "JSCConfig.h"
#import "JSCDebug.h"
#import "JSCWhitelist.h"
#import "JSCConfigParser.h"
#import "NSDictionary+JSCPreferences.h"

@interface JSCConfig ()
@property (nonatomic, strong) JSCWhitelist* allowIntentsWhitelist;
@property (nonatomic, strong) JSCWhitelist* allowNavigationsWhitelist;
@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, readwrite, strong) NSArray *startupPluginNames;
@property (nonatomic, readwrite, strong) NSDictionary *pluginsMap;
@property (nonatomic, copy) NSString *configFilePath;


@end

@implementation JSCConfig

- (instancetype)initWithPath:(NSString *)path{
    self = [super init];
    if (self) {
        _configFilePath = [[self p_pathWithCustomPath:path] copy];
    }
    return self;
}

#pragma mark - LoadSettings

- (BOOL)loadConfig{
    if (_configFilePath == nil) {
        return NO;
    }
    JSCConfigParser *configParser = [[JSCConfigParser alloc] init];
    NSURL* url = [NSURL fileURLWithPath:_configFilePath];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    if (configParser == nil) {
        JSCLog(@"ERROR: Failed to initialize XML parser. 'config.xml' will not be used");
        return NO;
    }
    xmlParser.delegate = configParser;
    [xmlParser parse];
    
    // Get the plugin dictionary, whitelist and settings from the delegate.
    self.pluginsMap = [[NSDictionary alloc] initWithDictionary:configParser.pluginsDict];
    self.startupPluginNames = [[NSArray alloc] initWithArray:configParser.startupPluginNames];
    self.settings = [[NSDictionary alloc] initWithDictionary:configParser.settings];
    self.allowIntentsWhitelist = [[JSCWhitelist alloc] initWithArray:configParser.allowIntents];
    self.allowNavigationsWhitelist = [[JSCWhitelist alloc] initWithArray:configParser.allowNavigations];
    return configParser.isParserSuccess;
}


- (NSString *)p_pathWithCustomPath:(NSString *)path{
    NSString* configPath = path ?: @"config.xml";
    
    // if path is relative, resolve it against the main bundle
    if(!configPath.isAbsolutePath){
        NSString* absolutePath = [[NSBundle mainBundle] pathForResource:configPath ofType:nil];
        if(!absolutePath){
            JSCLog(@"ERROR: %@ not found in the main bundle!", configPath);
            return nil;
        }
        configPath = absolutePath;
    }
    
    // Assert file exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
        JSCLog(@"ERROR: %@ does not exist.", configPath);
        return nil;
    }
    
    return configPath;
}


- (void)setSettingsForWebView:(UIWebView *)webView{
    if (webView == nil) {
        JSCLog(@"ERROR: webView is nil.");
        return;
    }
    
    webView.scalesPageToFit = [_settings jsCoreBridgeBoolSettingForKey:@"EnableViewportScale" defaultValue:NO];
    webView.allowsInlineMediaPlayback = [_settings jsCoreBridgeBoolSettingForKey:@"AllowInlineMediaPlayback" defaultValue:NO];
    webView.mediaPlaybackRequiresUserAction = [_settings jsCoreBridgeBoolSettingForKey:@"MediaPlaybackRequiresUserAction" defaultValue:YES];
    webView.mediaPlaybackAllowsAirPlay = [_settings jsCoreBridgeBoolSettingForKey:@"MediaPlaybackAllowsAirPlay" defaultValue:YES];
    webView.keyboardDisplayRequiresUserAction = [_settings jsCoreBridgeBoolSettingForKey:@"KeyboardDisplayRequiresUserAction" defaultValue:YES];
    webView.suppressesIncrementalRendering = [_settings jsCoreBridgeBoolSettingForKey:@"SuppressesIncrementalRendering" defaultValue:NO];
    webView.gapBetweenPages = [_settings jsCoreBridgeFloatSettingForKey:@"GapBetweenPages" defaultValue:0.0];
    webView.pageLength = [_settings jsCoreBridgeFloatSettingForKey:@"PageLength" defaultValue:0.0];
    
    id prefObj = nil;
    
    // By default, DisallowOverscroll is false (thus bounce is allowed)
    BOOL bounceAllowed = !([_settings jsCoreBridgeBoolSettingForKey:@"DisallowOverscroll" defaultValue:NO]);
    
    // prevent webView from bouncing
    if (!bounceAllowed) {
        webView.scrollView.bounces = NO;
    }
    
    NSString* decelerationSetting = [_settings jsCoreBridgeSettingForKey:@"UIWebViewDecelerationSpeed"];
    if (![@"fast" isEqualToString:decelerationSetting]) {
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    }
    
    NSInteger paginationBreakingMode = 0; // default - UIWebPaginationBreakingModePage
    prefObj = [_settings jsCoreBridgeSettingForKey:@"PaginationBreakingMode"];
    if (prefObj != nil) {
        NSArray* validValues = @[@"page", @"column"];
        NSString* prefValue = validValues[0];
        
        if ([prefObj isKindOfClass:[NSString class]]) {
            prefValue = prefObj;
        }
        
        paginationBreakingMode = [validValues indexOfObject:[prefValue lowercaseString]];
        if (paginationBreakingMode == NSNotFound) {
            paginationBreakingMode = 0;
        }
    }
    webView.paginationBreakingMode = paginationBreakingMode;
    
    NSInteger paginationMode = 0; // default - UIWebPaginationModeUnpaginated
    prefObj = [_settings jsCoreBridgeSettingForKey:@"PaginationMode"];
    if (prefObj != nil) {
        NSArray* validValues = @[@"unpaginated", @"lefttoright", @"toptobottom", @"bottomtotop", @"righttoleft"];
        NSString* prefValue = validValues[0];
        
        if ([prefObj isKindOfClass:[NSString class]]) {
            prefValue = prefObj;
        }
        
        paginationMode = [validValues indexOfObject:prefValue.lowercaseString];
        if (paginationMode == NSNotFound) {
            paginationMode = 0;
        }
    }
    webView.paginationMode = paginationMode;
}


#pragma mark - IntentAndNavigationFilter

- (BOOL)shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString* allowIntents_whitelistRejectionFormatString = @"ERROR External navigation rejected - <allow-intent> not set for url='%@'";
    NSString* allowNavigations_whitelistRejectionFormatString = @"ERROR Internal navigation rejected - <allow-navigation> not set for url='%@'";
    
    NSURL* url = request.URL;
    BOOL allowNavigationsPass = NO;
    NSMutableArray* errorLogs = [NSMutableArray array];
    
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked:
            // Note that the rejection strings will *only* print if
            // it's a link click (and url is not whitelisted by <allow-*>)
            if ([_allowIntentsWhitelist URLIsAllowed:url logFailure:NO]) {
                // the url *is* in a <allow-intent> tag, push to the system
                allowNavigationsPass = YES;
            } else {
                [errorLogs addObject:[NSString stringWithFormat:allowIntents_whitelistRejectionFormatString, url.absoluteString]];
            }
            // fall through, to check whether you can load this in the webview
        default:
            // check whether we can internally navigate to this url
            allowNavigationsPass = [_allowNavigationsWhitelist URLIsAllowed:url logFailure:NO];
            // log all failures only when this last filter fails
            if (!allowNavigationsPass){
                [errorLogs addObject:[NSString stringWithFormat:allowNavigations_whitelistRejectionFormatString, url.absoluteString]];
                
#ifdef DEBUG
                // this is the last filter and it failed, now print out all previous error logs
                for (NSString* errorLog in errorLogs) {
                    JSCLog(@"%@", errorLog);
                }
#endif
            }
            
            return allowNavigationsPass;
    }
}


@end
