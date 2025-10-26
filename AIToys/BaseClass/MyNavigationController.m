//
//  MyNavigationController.m
//  HelloBrother
//
//  Created by 乔不赖 on 2024/1/15.
//

#import "MyNavigationController.h"
#import "ATFontManager.h"

@interface MyNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation MyNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.delegate = self;
    //设置默认导航栏毛玻璃效果、导航栏颜色、标题字体和颜色
    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setBarTintColor:UIColor.whiteColor];
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
      [self.navigationBar setShadowImage:[UIImage new]];
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [ATFontManager boldSystemFontOfSize:17], NSForegroundColorAttributeName : [UIColor blackColor]}];
    //设置默认左右按钮文字颜色、字体大小
    [self.navigationBar setTintColor:[UIColor.whiteColor colorWithAlphaComponent:0.8]];
    NSDictionary *dic = @{NSFontAttributeName : [ATFontManager systemFontOfSize:15]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:dic forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:dic forState:UIControlStateHighlighted];
    
    //返回按钮图片设置
    self.navigationBar.backIndicatorImage = [[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationBar.backIndicatorTransitionMaskImage = [[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.interactivePopGestureRecognizer.delegate = self;
    [self configUIBarAppearance];
}

- (void)configUIBarAppearance {
    if (@available(iOS 13.0, *)) {
        ///NaviBar
        UINavigationBarAppearance *naviBarAppearance = [[UINavigationBarAppearance alloc] init];
        if (self.navigationBar.isTranslucent) {
            UIColor *barTintColor = self.navigationBar.barTintColor;
            naviBarAppearance.backgroundColor = [barTintColor colorWithAlphaComponent:0.85];
        } else {
            naviBarAppearance.backgroundColor = self.navigationBar.barTintColor;
        }
        naviBarAppearance.titleTextAttributes = self.navigationBar.titleTextAttributes;
        self.navigationBar.standardAppearance = naviBarAppearance;
        self.navigationBar.scrollEdgeAppearance = naviBarAppearance;
        
        
        ///ToolBar
        UIToolbarAppearance *toolBarAppearance = [[UIToolbarAppearance alloc] init];
        if (self.toolbar.isTranslucent) {
            UIColor *barTintColor = self.toolbar.barTintColor;
            toolBarAppearance.backgroundColor = [barTintColor colorWithAlphaComponent:0.85];
        } else {
            toolBarAppearance.backgroundColor = self.navigationBar.barTintColor;
        }
        self.toolbar.standardAppearance = toolBarAppearance;
        if (@available(iOS 15.0, *)) {
            self.toolbar.scrollEdgeAppearance = toolBarAppearance;
        }
    }
    //分割线
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
