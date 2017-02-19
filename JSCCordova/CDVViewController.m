//
//  CDVViewController.m
//  JSCCordova
//
//  Created by iPhuan on 2017/2/19.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "CDVViewController.h"
#import "CDVPlugin.h"

@interface CDVViewController ()

@end

@implementation CDVViewController

@synthesize configFile = _configFile;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)configFile{
    return self.configFilePath;
}

- (void)setConfigFile:(NSString *)configFile{
    self.configFilePath = configFile;
}

- (id)commandDelegate{
    return self.bridgeDelegate;
}

- (JSCPlugin *)getCommandInstance:(NSString *)pluginName {
    return [self.bridgeDelegate getPluginInstance:pluginName];
}

- (void)registerPlugin:(CDVPlugin *)plugin withPluginName:(NSString *)pluginName {
    [self.bridgeDelegate registerPlugin:plugin withPluginName:pluginName];
}



@end
