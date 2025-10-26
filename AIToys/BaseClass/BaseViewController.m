//
//  BaseViewController.m
//  AIToys
//
//  Created by qdkj on 2025/6/17.
//

#import "BaseViewController.h"
#import "UIImage+Extension.h"
#import "LoginViewController.h"

@interface BaseViewController ()
@property (nonatomic, strong) UIImageView *shadowImage;
@end

@implementation BaseViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 导航栏颜色
    if (self.changeNavColor) {
        [self.navigationController.navigationBar setBarTintColor:UIColor.whiteColor];
        [self configUIBarAppearance];
    }
    
    //去除导航栏下方的横线
    NSArray *subViews = allSubviews(self.navigationController.navigationBar);
     for (UIView *view in subViews) {
       if ([view isKindOfClass:[UIImageView class]] && view.bounds.size.height<1){
        //实践后发现系统的横线高度为0.333
         self.shadowImage = (UIImageView *)view;
       }
     }
     self.shadowImage.hidden = YES;
    
    if (self.hj_NavIsHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
    
}

NSArray *allSubviews(UIView *aView) {
 NSArray *results = [aView subviews];
 for (UIView *eachView in aView.subviews)
 {
   NSArray *subviews = allSubviews(eachView);
   if (subviews)
     results = [results arrayByAddingObjectsFromArray:subviews];
 }
 return results;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.changeNavColor) {
        [self.navigationController.navigationBar setBarTintColor:mainColor];
        [self configUIBarAppearance];
    }
    if (self.hj_NavIsHidden) {
        if ([self hj_pushOrPopIsHidden] == NO) {
            [self.navigationController setNavigationBarHidden:NO animated:animated];
        }
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bgViewColor;
    [self setupNavBackBtn];
}

- (void)setupNavBackBtn {
    if (self.navigationController.viewControllers.count <= 1) {
        return;
    }
    
    if (@available(iOS 15.0, *)) {
        UIButtonConfiguration *config = [UIButtonConfiguration plainButtonConfiguration];
        config.image = [[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        config.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, 0, 0);
        
        self.leftBarButton = [UIButton buttonWithConfiguration:config primaryAction:nil];
        [self.leftBarButton addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        // 让按钮自适应内容大小
        [self.leftBarButton sizeToFit];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBarButton];
        
        
    } else {
        // iOS 15 以下的兼容方案
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        // 让按钮自适应内容大小
        [backButton sizeToFit];
        
        self.leftBarButton = backButton;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
}

- (void)leftButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)configUIBarAppearance {
    //分割线
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    if (@available(iOS 13.0, *)) {
        ///NaviBar
        UINavigationBarAppearance *naviBarAppearance = [[UINavigationBarAppearance alloc] init];
        if (self.navigationController.navigationBar.isTranslucent) {
            UIColor *barTintColor = self.navigationController.navigationBar.barTintColor;
            naviBarAppearance.backgroundColor = [barTintColor colorWithAlphaComponent:0.85];
        } else {
            naviBarAppearance.backgroundColor = self.navigationController.navigationBar.barTintColor;
        }
        naviBarAppearance.titleTextAttributes = self.navigationController.navigationBar.titleTextAttributes;
        self.navigationController.navigationBar.standardAppearance = naviBarAppearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = naviBarAppearance;
        
        
        ///ToolBar
        UIToolbarAppearance *toolBarAppearance = [[UIToolbarAppearance alloc] init];
        if (self.navigationController.toolbar.isTranslucent) {
            UIColor *barTintColor = self.navigationController.toolbar.barTintColor;
            toolBarAppearance.backgroundColor = [barTintColor colorWithAlphaComponent:0.85];
        } else {
            toolBarAppearance.backgroundColor = self.navigationController.navigationBar.barTintColor;
        }
        self.navigationController.toolbar.standardAppearance = toolBarAppearance;
        if (@available(iOS 15.0, *)) {
            self.navigationController.toolbar.scrollEdgeAppearance = toolBarAppearance;
        }
    }
}

///监听push下一个或 pop 上一个，是否隐藏导航栏
- (BOOL)hj_pushOrPopIsHidden {
    NSArray * viewcontrollers = self.navigationController.viewControllers;
    if (viewcontrollers.count > 0) {
        if([viewcontrollers[viewcontrollers.count - 1] isKindOfClass:[BaseViewController class]]){
            BaseViewController * vc = viewcontrollers[viewcontrollers.count - 1];
            return vc.hj_NavIsHidden;
        }
    }
    return NO;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(NSString *)getMemeberRoleName:(ThingHomeRoleType )role{
    NSString *roleStr = LocalString(@"未知");
    switch (role) {
        case ThingHomeRoleType_Owner:
            roleStr = LocalString(@"家庭所有者");
            break;
        case ThingHomeRoleType_Member:
            roleStr = LocalString(@"普通成员");
            break;
        case ThingHomeRoleType_Admin:
            roleStr = LocalString(@"管理员");
            break;
            
        default:
            
            break;
    }
    return roleStr;
}

//显示加载框
-(void)showHud{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"loading" ofType:@"gif"]; // 替换为你的GIF文件路径
    NSData  *imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage *gifImg = [[UIImage sd_imageWithGIFData:imageData] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [SVProgressHUD setMinimumDismissTimeInterval:90];
    [SVProgressHUD setImageViewSize:CGSizeMake(55, 55)];
    [SVProgressHUD showImage:gifImg status:nil];
    [SVProgressHUD setShouldTintImages:false];
}

//隐藏加载框
-(void)hiddenHud{
    [SVProgressHUD setMinimumDismissTimeInterval:3];
    [SVProgressHUD setImageViewSize:CGSizeMake(24, 24)];
    [SVProgressHUD dismiss];
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
