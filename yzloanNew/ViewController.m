//
//  ViewController.m
//  yzloanNew
//
//  Created by 苏文彬 on 2018/12/22.
//  Copyright © 2018年 yinzhong. All rights reserved.
//

#import "ViewController.h"
#import "YZWebViewViewController.h"
#import "WebViewJavascriptBridge.h"
#import "NSUtil.h"

@interface ViewController ()

@property(nonatomic,strong) NSDictionary *dataDict;
@property(nonatomic,strong) UIWebView *webView;
@property WebViewJavascriptBridge* bridge;

#define URLSTRING @"http://app.yioucash.com/test/index.html"


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];

}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewwillappear");
    [self registerBridge];
    [self loadRequst];
//    [self loadExamplePage];
}

-(void)loadRequst
{
    NSURL *url = [NSURL URLWithString:URLSTRING];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
}

- (void)registerBridge
{
    if (_bridge) { return; }
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge setWebViewDelegate:self];
    
    [_bridge registerHandler:@"window.app.getInfo()" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"JS Bridge called: %@", data);
        /* app当前版本号 */
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = infoDict[@"CFBundleShortVersionString"];
        
        NSString *uuid = [NSUtil getUUID];
        NSString *client = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        
        NSDictionary *dictCallBack = [NSDictionary dictionaryWithObjectsAndKeys:uuid,@"deviceId",client,@"client",currentVersion,@"versonName",@"",@"channel", nil];
        
        
        responseCallback(dictCallBack);
    }];
    
    [_bridge registerHandler:@"window.app.toThreeProduct()" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
//        [self openWebViewController:data];
        [self performSelectorOnMainThread:@selector(openWebViewController:) withObject:data waitUntilDone:NO];
    }];
    
}

-(UIWebView *)webView
{
    if(!_webView){
        //获取状态栏的rect
        CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
        _webView = [[UIWebView alloc ]initWithFrame:CGRectMake(0, statusRect.size.height, self.view.bounds.size.width, self.view.bounds.size.height - statusRect.size.height)];
        [self.view addSubview:_webView];
    }
    return _webView;
}


- (void)loadExamplePage {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadHTMLString:appHtml baseURL:baseURL];
}


- (void)openWebViewController:(id)data
{
    
    YZWebViewViewController *yzWebViewController = [[YZWebViewViewController alloc ]initWithDict:data];
    [self presentViewController:yzWebViewController animated:YES completion:nil];
//    UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    while (topRootViewController.presentedViewController)
//    {
//        topRootViewController = topRootViewController.presentedViewController;
//    }
//    
//    [topRootViewController presentViewController:yzWebViewController animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *url = webView.request.URL.absoluteString;
    NSLog(@"currentURL == %@",url);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}


@end
