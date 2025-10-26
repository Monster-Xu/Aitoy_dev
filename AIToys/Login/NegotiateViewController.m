//
//  NegotiateViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/9/26.
//

#import "NegotiateViewController.h"

@interface NegotiateViewController ()

@end

@implementation NegotiateViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配置WKWebView
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    // 加载文档
    NSURL * fileURL = [NSURL new];
    NSBundle *bundle = [NSBundle mainBundle];
    switch (self.type) {
        case 0:
            fileURL = [bundle URLForResource:@"Talenpal_User_Privacy_Policy" withExtension:@"docx"];
            break;

        case 1:
            fileURL = [bundle URLForResource:@"Talenpal_Terms_of_Use" withExtension:@"docx"];
            break;

        case 2:
            fileURL = [bundle URLForResource:@"Talenpal_Childrens_Privacy_Agreement" withExtension:@"docx"];
            break;

        case 3:
            fileURL = [bundle URLForResource:@"Talenpal_Content_Creation_User_Agreement_EN" withExtension:@"docx"];
            break;

        default:
            break;
    }

    if (fileURL) {
        // WKWebView 需要使用 loadFileURL:allowingReadAccessToURL: 方法加载本地文件
        [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL.URLByDeletingLastPathComponent];
    } else {
        NSLog(@"文档文件未找到");
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败: %@", error.localizedDescription);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"文档加载完成");
}

@end


