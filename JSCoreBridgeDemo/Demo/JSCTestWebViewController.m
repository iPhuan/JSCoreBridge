//
//  JSCTestWebViewController.m
//  JSCoreBridgeDemo
//
//  Created by iPhuan on 2017/2/12.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "JSCTestWebViewController.h"

@interface JSCTestWebViewController (){
    NSTimer *_progressTimer;
}
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong) NSURL *URL;

@end

@implementation JSCTestWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 通过fitContentTop设置正确的top值
    _progressView.frame = CGRectMake(0, self.fitContentTop, _progressView.frame.size.width, _progressView.frame.size.height);

    // 调用loadURL方法手动加载网页
    [self loadURL:_URL];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self p_invalidateTimer];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (instancetype)initWithUrl:(NSString *)url {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _URL = [NSURL URLWithString:url];
        
        // 关闭自动加载页面
        self.shouldAutoLoadURL = NO;
//        //可以指定config.xml的路径为沙盒目录或者Bundle的子目录下
//        self.configFilePath = @"";
//        //可以关闭config配置选项，JSCoreBridge将不再使用config.xml配置项；当使用JSCoreBridgeLite时，config无效
//        self.configEnabled = NO;
    }
    return self;
}

#pragma mark - jsCoreBridge WebView delegate

- (BOOL)jsCoreBridgeWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    // override this if you need to handle request URL

    return YES;
}

- (void)jsCoreBridgeWebViewDidStartLoad:(UIWebView *)webView{
    // override this if you need to do something when webView start load

    [self p_startProgress];
}

- (void)jsCoreBridgeWebViewDidFinishLoad:(UIWebView *)webView{
    // override this if you need to do something when webView finish load

    [self p_invalidateTimer];
    _progressView.progress = 1;
    [self performSelector:@selector(p_hideProgress) withObject:nil afterDelay:0.3];
}

- (void)jsCoreBridgeWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    // override this if you need to do something when webView fail load

    [self p_invalidateTimer];
    [self p_hideProgress];
}

// deviceready之前调用该方法
- (void)jsCoreBridgeWillReady:(UIWebView *)webView{
    // override this if you need to do something when jsCoreBridge will call 'deviceready'
    
}

// deviceready之后调用该方法，如果你在deviceready监听函数里面调用了JS jsCoreBridge.exec方法，不要企望客户端对应的插件方法会在该方法之前调用，因为JS方法是异步的，客户端执行其操作并不是及时的，除非你使用jsCoreBridge.execSync
- (void)jsCoreBridgeDidReady:(UIWebView *)webView{
    // override this if you need to do something when jsCoreBridge has already called 'deviceready'

}

#pragma mark - Progress

- (void)p_startProgress{
    _progressView.hidden = NO;
    _progressView.progress = 0;
    [_progressView setProgress:0.25 animated:YES];
    
    [self p_invalidateTimer];
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(p_changeProgress) userInfo:nil repeats:YES];
}

- (void)p_invalidateTimer{
    if (_progressTimer) {
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
}

- (void)p_changeProgress{
    if (_progressView.progress < 0.75) {
        _progressView.progress += 0.04;
    }else if (_progressView.progress >= 0.75 && _progressView.progress < 0.9){
        _progressView.progress += 0.01;
    }
}


- (void)p_hideProgress{
    _progressView.progress = 0;
    _progressView.hidden =YES;
}

@end
