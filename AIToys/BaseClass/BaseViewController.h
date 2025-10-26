//
//  BaseViewController.h
//  AIToys
//
//  Created by qdkj on 2025/6/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
@property (nonatomic, assign)BOOL changeNavColor;
///是否隐藏导航栏 默认 NO 不隐藏
@property (nonatomic, assign) BOOL hj_NavIsHidden;
@property (nonatomic, strong)UIButton *leftBarButton;
@property (nonatomic, strong)UIButton * rightBtn;

- (void)setupNavBackBtn;

-(NSString *)getMemeberRoleName:(ThingHomeRoleType )role;

//显示加载框
-(void)showHud;

//隐藏加载框
-(void)hiddenHud;
@end

NS_ASSUME_NONNULL_END
