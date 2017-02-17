//
//  ViewController.m
//  JSCoreBridgeDemo
//
//  Created by iPhuan on 2017/2/10.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "ViewController.h"
#import "JSCTestWebViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onJsCoreBridgeDemoBtn:(id)sender {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@",bundlePath,@"web/index.html"];
    htmlPath = @"https://commonwappre.10101111.com/join?key=bjhKRzlQd0FIL2RRektQbVMxYlpQUDVPNzlyQk1RSXVVZVRuYVV3QWFEcW1PMm51bXBlVkxvcUNzOXRwYjBjL09PMlFoUlBnL2JidkowTkx6dnBxcGVwdU1CdGdQWGE0cnRodng5WnBBd1k9";
    JSCTestWebViewController *VC = [[JSCTestWebViewController alloc] initWithUrl:htmlPath];
    [self.navigationController pushViewController:VC animated:YES];
}

@end
