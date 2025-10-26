//
//  MyTabBarControllerViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/18.
//

#import "MyTabBarController.h"
#import "HomeViewController.h"
#import "ContactViewController.h"
#import "CreationViewController.h"
#import "MineViewController.h"
#import "LoginViewController.h"
#import <ThingSmartMiniAppBizBundle/ThingSmartMiniAppBizBundle.h>

@interface MyTabBarController ()<UITabBarControllerDelegate>

@end

@implementation MyTabBarController

+ (void)initialize {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = generalTextColor;
    
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = mainColor;
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:KEY_ISFIRSTLAUNCH]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_ISFIRSTLAUNCH];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.tabBar.tintColor = mainColor;
    
    // ✅ 首先创建子控制器
    [self addAllChildViewController];
    
    // ✅ 然后配置外观
    [self configureTabBarAppearance];
    
    //监听SDK会话是否超时
    [self loadNotification];
    //为了初始化网络监听
    [[APIManager shared] getCurrentViewController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // ✅ 强制刷新 TabBar 显示
    [self refreshTabBarTitles];
}

/// 配置 TabBar 外观
- (void)configureTabBarAppearance {
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        
        // ✅ 使用默认配置作为基础
        [appearance configureWithDefaultBackground];
        
        // 设置背景
        appearance.backgroundColor = [UIColor whiteColor];
        appearance.backgroundEffect = nil;
        appearance.shadowColor = nil;
        
        // ⭐️ 更明确的文字样式配置
        NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
        normalAttrs[NSForegroundColorAttributeName] = generalTextColor ?: [UIColor blackColor];
        normalAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:10]; // 确保有字体
        
        NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
        selectedAttrs[NSForegroundColorAttributeName] = mainColor ?: [UIColor systemBlueColor];
        selectedAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:10]; // 确保有字体
        
        // ✅ 设置所有可能的布局状态
        [appearance.stackedLayoutAppearance.normal setTitleTextAttributes:normalAttrs];
        [appearance.stackedLayoutAppearance.selected setTitleTextAttributes:selectedAttrs];
        [appearance.inlineLayoutAppearance.normal setTitleTextAttributes:normalAttrs];
        [appearance.inlineLayoutAppearance.selected setTitleTextAttributes:selectedAttrs];
        [appearance.compactInlineLayoutAppearance.normal setTitleTextAttributes:normalAttrs];
        [appearance.compactInlineLayoutAppearance.selected setTitleTextAttributes:selectedAttrs];
        
        // ✅ 确保标题位置正确
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffsetMake(0, 0);
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffsetMake(0, 0);
        
        // 设置毛玻璃背景
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, TabBar_Height);
        appearance.backgroundImage = [PublicObj imageWithUIView:effectView];
        
        // ⭐️ 应用外观
        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance = appearance;
    }
}

/// 强制刷新 TabBar 标题显示
- (void)refreshTabBarTitles {
    // ✅ 强制重新设置所有 TabBarItem 的标题
    for (int i = 0; i < self.tabBar.items.count; i++) {
        UITabBarItem *item = self.tabBar.items[i];
        
        if (item.title && item.title.length > 0) {
            NSString *originalTitle = item.title;
            item.title = nil;
            item.title = originalTitle;
        } else {
            // ⭐️ 如果标题为空，尝试从子控制器恢复
            if (i < self.childViewControllers.count) {
                UIViewController *childVC = self.childViewControllers[i];
                if ([childVC isKindOfClass:[UINavigationController class]]) {
                    UINavigationController *nav = (UINavigationController *)childVC;
                    UIViewController *rootVC = nav.viewControllers.firstObject;
                    
                    NSString *expectedTitle = nil;
                    if ([rootVC isKindOfClass:[HomeViewController class]]) {
                        expectedTitle = LocalString(@"首页");
                    } else if ([rootVC isKindOfClass:[CreationViewController class]]) {
                        expectedTitle = LocalString(@"创作");
                    } else if ([rootVC isKindOfClass:[MineViewController class]]) {
                        expectedTitle = LocalString(@"我的");
                    }
                    
                    if (expectedTitle) {
                        item.title = expectedTitle;
                    }
                }
            }
        }
    }
    
    // ✅ 强制刷新 TabBar
    [self.tabBar setNeedsLayout];
    [self.tabBar layoutIfNeeded];
}

#pragma mark - Private Methods

- (void)addAllChildViewController {
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    [self addChildViewController:homeVC
                           image:@"tab_home"
                   selectedImage:@"tab_home_sel"
                           title:LocalString(@"首页")];
    
    CreationViewController *creationVC = [[CreationViewController alloc] init];
    [self addChildViewController:creationVC
                           image:@"tab_create"
                   selectedImage:@"tab_create_sel"
                           title:LocalString(@"创作")];
    
//    ContactViewController *contactVC = [[ContactViewController alloc] init];
//    [self addChildViewController:contactVC
//                           image:@"tab_contact"
//                   selectedImage:@"tab_contact_sel"
//                           title:LocalString(@"通讯")];
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    [self addChildViewController:mineVC
                           image:@"tab_mine"
                   selectedImage:@"tab_mine_sel"
                           title:LocalString(@"我的")];
}

- (void)addChildViewController:(UIViewController *)vc
                         image:(NSString *)imgName
                 selectedImage:(NSString *)selImgName
                         title:(NSString *)title
{
    // ✅ 确保标题不为空
    NSString *finalTitle = title ?: @"";
    
    // ✅ 设置 TabBarItem
    vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:finalTitle
                                                  image:[[UIImage imageNamed:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                          selectedImage:[[UIImage imageNamed:selImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // ✅ 验证 TabBarItem 创建是否成功
    if (!vc.tabBarItem.title || vc.tabBarItem.title.length == 0) {
        vc.tabBarItem.title = finalTitle;
    }
    
    // ✅ 明确设置标题文本属性（作为备用方案）
    NSDictionary *normalAttrs = @{
        NSForegroundColorAttributeName: generalTextColor ?: [UIColor blackColor],
        NSFontAttributeName: [UIFont systemFontOfSize:10]
    };
    
    NSDictionary *selectedAttrs = @{
        NSForegroundColorAttributeName: mainColor ?: [UIColor systemBlueColor],
        NSFontAttributeName: [UIFont systemFontOfSize:10]
    };
    
    [vc.tabBarItem setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [vc.tabBarItem setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    
    // 设置控制器标题
    vc.title = finalTitle;
    
    MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
}

//处理登录会话过期
- (void)loadNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInvalid) name:ThingSmartUserNotificationUserSessionInvalid object:nil];
}

- (void)sessionInvalid {
    [LGBaseAlertView showAlertWithTitle:@"" content:LocalString(@"登录信息已过期,请重新登录") cancelBtnStr:nil confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
        if (isValue){
            
        }
    }];
    [UserInfo clearMyUser];
    [CoreArchive removeStrForKey:KCURRENT_HOME_ID];
    [UserInfo showLogin];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ThingSmartUserNotificationUserSessionInvalid object:nil];
}

#pragma mark - Event Methods

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    // ✅ 每次切换时检查并修复标题显示
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshTabBarTitles];
    });
    
    return YES;
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
