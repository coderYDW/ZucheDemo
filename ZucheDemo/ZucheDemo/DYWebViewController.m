//
//  DYWebViewController.m
//  ZucheDemo
//
//  Created by Yangdongwu on 2017/7/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYWebViewController.h"
#import "DYJSObject.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol DYJSExport <JSExport>

- (void)print:(NSString *)str;

- (void)callChangeColor;

@end

@interface DYWebViewController () <UIWebViewDelegate,DYJSExport>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation DYWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
       
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jsTest" ofType:@"html"];
    NSURL *url = [[NSURL alloc]initFileURLWithPath:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
//    [self jsObject];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateJSContext:) name:@"DidCreateContextNotification" object:nil];
    
}

- (void)didCreateJSContext:(NSNotification *)notification {
    
    NSString *indentifier = [NSString stringWithFormat:@"indentifier%lud", (unsigned long)self.webView.hash];
    NSString *indentifierJS = [NSString stringWithFormat:@"var %@ = '%@'", indentifier, indentifier];
    [self.webView stringByEvaluatingJavaScriptFromString:indentifierJS];
    
    JSContext *context = notification.object;
    //判断这个context是否属于当前这个webView
    if (![context[indentifier].toString isEqualToString:indentifier]) return;

    self.jsContext = context;
    [self jsObject:context];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.webView.frame = self.view.bounds;

    
}

- (void)jsObject:(JSContext *)jsContext {

    //NSLog(@"加载完成");
    //获取执行环境
    //JSContext *jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //self.jsContext = jsContext;
    //注册响应参数对象
    DYJSObject *jsObj = [[DYJSObject alloc] init];
    [jsContext setObject:jsObj forKeyedSubscript:@"ttf"];
    [jsContext setObject:self forKeyedSubscript:@"change"];
    
    //点击了无参数，jstoocNoPrams是JS的方法名称
    jsContext[@"jstoocNoPrams"] = ^(){
        
        NSLog(@"点击了没有传参数按钮");
    
    };
    
    
    //点击传参数 jstoocHavePrams方法名称
    jsContext[@"jstoocHavePrams"] = ^(){
        //获得参数
        NSArray *prams = [JSContext currentArguments];
        
        NSString *arraySting = [[NSString alloc]init];
        for (id obj in prams) {
            NSLog(@"====%@",obj);
            arraySting = [arraySting stringByAppendingFormat:@"%@,",obj];
        }
        
    };
    
//    __weak typeof(jsContext) weakContext = jsContext;
    
    jsContext[@"jsToOCAndOCToJS"] = ^(NSString *name1, NSString *name2, NSInteger age){
    
        //[weakContext evaluateScript:[NSString stringWithFormat:@"locationFunction('%@')",name]];
        
        NSArray *values = [JSContext currentArguments];
        
        for (JSValue *value in values) {
            NSLog(@"%@",value);
        }
        
        NSLog(@"name1 = %@, name2 = %@, age = %zd",name1, name2, age);
        
    };
    
}

- (void)print:(NSString *)str {

    NSLog(@"%@",str);
    
}

- (void)callChangeColor
{
    self.webView.backgroundColor = [self getRandColor];
}

- (UIColor *)getRandColor
{
    return [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:255.0/255.0];
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

@end
