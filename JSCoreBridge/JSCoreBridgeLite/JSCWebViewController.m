//
//  JSCWebViewController.m
//  JSCoreBridge
//
//  Created by iPhuan on 2016/11/29.
//  Copyright © 2016年 iPhuan. All rights reserved.
//

#import "JSCWebViewController.h"
#import "JSCBridge.h"



@interface JSCWebViewController ()

@property (nonatomic, strong) JSCBridge *bridge;
@property (nonatomic, readwrite, strong) UIWebView *webView;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, readwrite, assign) CGFloat fitContentTop;
@property (nonatomic, readwrite, assign) CGFloat fitContentHeight;


@end

@implementation JSCWebViewController

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = [UIScreen mainScreen].bounds;
    self.view.frame = frame;
    self.webView = [[UIWebView alloc] initWithFrame:frame];
    _webView.delegate = _bridge;
    
    BOOL navigationBarHidden = self.navigationController.navigationBarHidden || self.navigationController.navigationBar.hidden;
    if (!self.prefersStatusBarHidden && !navigationBarHidden) {
        [self p_adjustWebViewWithNavigationBar];
    }else if (!self.prefersStatusBarHidden && navigationBarHidden){
        [self p_adjustWebViewWithoutNavigationBar];
    }

    _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view insertSubview:_webView atIndex:0];
    [_bridge webViewControllerViewDidLoad];
    
    if (_shouldAutoLoadURL) {
        [self loadURL:_URL];
    }
}

- (void)p_adjustWebViewWithNavigationBar{
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    CGFloat navigationBarHeight = navigationBar.frame.size.height;
    CGFloat topHeight = navigationBar.frame.origin.y + navigationBarHeight;
    if (navigationBar.isTranslucent) {
        [self p_setScrollViewContentInsetWithTop:topHeight];
    }else {
        self.fitContentHeight -= topHeight;
    }
}

- (void)p_adjustWebViewWithoutNavigationBar{
    CGFloat topHeight = 20;
    [self p_setScrollViewContentInsetWithTop:topHeight];
    self.fitContentHeight -= topHeight;
}

- (void)p_setScrollViewContentInsetWithTop:(CGFloat)top{
    self.fitContentTop = top;
    _webView.scrollView.contentInset = UIEdgeInsetsMake(_fitContentTop, 0, -_fitContentTop, 0);
    _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(_fitContentTop, 0, 0, 0);
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _webView.scrollView.contentInset = UIEdgeInsetsMake(_webView.scrollView.contentInset.top, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - init

- (instancetype)initWithUrl:(NSString *)url{
    self = [super init];
    if (self) {
        _URL = [NSURL URLWithString:url];
        [self p_init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self p_init];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self p_init];
    return self;
}

- (id)init{
    self = [super init];
    [self p_init];
    return self;
}

- (void)p_init{
    if (self) {
        _bridge = [[JSCBridge alloc] initWithWebViewController:self];
        _configEnabled = YES;
        _shouldAutoLoadURL = YES;
        _fitContentTop = 0;
        _fitContentHeight = [UIScreen mainScreen].bounds.size.height;
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        if (navigationBar.isTranslucent) {
            self.navigationController.edgesForExtendedLayout = UIRectEdgeAll;
        }else{
            self.navigationController.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
}

#pragma mark - Set or Get

- (id <JSCBridgeDelegate>)bridgeDelegate{
    return _bridge.bridgeDelegate;
}


#pragma mark - Orientations

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    UIInterfaceOrientationMask ret = 0;
    
    if ([_bridge supportsOrientation:UIInterfaceOrientationPortrait]) {
        ret = ret | (1 << UIInterfaceOrientationPortrait);
    }
    if ([_bridge supportsOrientation:UIInterfaceOrientationPortraitUpsideDown]) {
        ret = ret | (1 << UIInterfaceOrientationPortraitUpsideDown);
    }
    if ([_bridge supportsOrientation:UIInterfaceOrientationLandscapeRight]) {
        ret = ret | (1 << UIInterfaceOrientationLandscapeRight);
    }
    if ([_bridge supportsOrientation:UIInterfaceOrientationLandscapeLeft]) {
        ret = ret | (1 << UIInterfaceOrientationLandscapeLeft);
    }
    
    return ret;
}

#pragma mark - WebView load

- (void)loadURL:(NSURL *)URL{
    [_bridge loadURL:URL];
}
- (void)loadHTMLString:(NSString *)htmlString{
    [_bridge loadHTMLString:htmlString];
}

#pragma mark - jsCoreBridge WebView delegate

- (BOOL)jsCoreBridgeWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    // override this if you need to handle request URL

    return YES;
}

- (void)jsCoreBridgeWebViewDidStartLoad:(UIWebView *)webView{
    // override this if you need to do something when webView start load
}

- (void)jsCoreBridgeWebViewDidFinishLoad:(UIWebView *)webView{
    // override this if you need to do something when webView finish load
}

- (void)jsCoreBridgeWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    // override this if you need to do something when webView fail load
}

- (void)jsCoreBridgeWillReady:(UIWebView *)webView{
    // override this if you need to do something when jsCoreBridge will call 'deviceready'
}
- (void)jsCoreBridgeDidReady:(UIWebView *)webView{
    // override this if you need to do something when jsCoreBridge has already called 'deviceready'
}


@end
