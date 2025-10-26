//
//  NegotiateViewController.h
//  AIToys
//
//  Created by xuxuxu on 2025/9/26.
//

#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface NegotiateViewController : BaseViewController<WKNavigationDelegate>
@property (strong, nonatomic) WKWebView *webView;
@property (assign,nonatomic)NSInteger type;//0:隐私政策 1:用户协议 2:儿童协议 3:创作协议


@end

NS_ASSUME_NONNULL_END
