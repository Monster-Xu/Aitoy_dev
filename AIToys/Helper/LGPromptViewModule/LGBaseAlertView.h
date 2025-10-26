//
//  LGBaseAlertView.h
//  QiDianProhibit
//
//  Created by KWOK on 2019/4/24.
//  Copyright © 2019 Henan Qidian Network Technology Co. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LGTextView;
typedef NS_ENUM(NSInteger, ALERT_VIEW_TYPE){
    ALERT_VIEW_TYPE_NORMAL = 0,
    ALERT_VIEW_TYPE_NORMAL_REJECT = 1,
    ALERT_VIEW_TYPE_NORMAL_VEHICLE = 2,
    ALERT_VIEW_TYPE_NORMAL_VERTION = 3,
    ALERT_VIEW_TYPE_NORMAL_CANCEL = 4,
    ALERT_VIEW_TYPE_EditName = 5,
    ALERT_VIEW_TYPE_EditText = 6,
};
@interface LGBaseAlertView : UIView

//图片
@property (nonatomic, strong) UIImageView* imgView;
//标题
@property(nonatomic, strong) UILabel* titleLabel;
//子标题
@property (nonatomic, strong) UILabel* subLabel;
//内容
@property(nonatomic, strong) UILabel* contentLabel;
//金豆详情
@property(nonatomic, strong) UILabel* detaileLab;;
//线
@property (nonatomic, strong) UIView* lineView;
@property (nonatomic, strong) UIView* midlleView;
//取消按钮
@property (nonatomic, strong) UIButton* cancelBtn;
//确定按钮
@property (nonatomic, strong) UIButton* confirmBtn;

@property (nonatomic, strong) LGTextView *textView;

@property (nonatomic, strong) UITextField *textField;


//车辆信息
@property (nonatomic, strong) UILabel *vehicleTitle;
@property (nonatomic, strong) UILabel *vehicleLab;
@property (nonatomic, strong) UILabel *typeTitle;
@property (nonatomic, strong) UILabel *typeLab;
@property (nonatomic, strong) UILabel *standardTitle;
@property (nonatomic, strong) UILabel *standardLab;
@property (nonatomic, strong) UILabel *timeTitle;
@property (nonatomic, strong) UILabel *TimeLab;


//承载的view
@property (nonatomic, strong) UIView* bgView;
//弹窗类型
@property (nonatomic, assign) ALERT_VIEW_TYPE type;

//允许区域外点击消失
@property (nonatomic, assign) BOOL isAllowDismiss;

@property (nonatomic, strong) CAShapeLayer* bgLayer;
//数据
@property (nonatomic, strong) id info;
@property(nonatomic, copy)void (^block)(BOOL, id);
//最后的对象
@property (nonatomic, strong) id lastObj;
@property (nonatomic, assign) CGFloat lastHeight;

- (void)layoutALERT_VIEW;
- (void)btnSelect:(UIButton* )btn;

/**
 ALERT_VIEW初始化方法
 自定义弹窗、根据type类型自定义ALERT_VIEW
 
 @param info 传入的json数据
 如：{@"title":@"", @"subTitle":@"", @"content":@"", @"imgStr":@""},相应的字段需要提前约束好
 @param type ALERT_VIEW类型
 @param block 点击的回调
 */
+ (LGBaseAlertView* )showAlertInfo:(id)info withType:(ALERT_VIEW_TYPE )type confirmBlock:(void (^)(BOOL is_value, id obj))block;


/**
 默认弹窗，只提供基本的标题、内容、按钮
 这个方法相当于 showALERT_VIEWInfo:(id)info withType:(ALERT_VIEW_TYPE )type confirmBlock:(void (^)(BOOL, id))block 选择了ALERT_VIEW_TYPE_NORMAL

 @param titleStr 标题
 @param contentStr 内容
 @param cancelStr 取消按钮
 @param confirmStr 确定按钮
 @param block 返回block
 @return 返回实体对象
 */
+ (LGBaseAlertView* )showAlertWithTitle:(NSString *)titleStr content:(NSString *)contentStr cancelBtnStr:(NSString *)cancelStr confirmBtnStr:(NSString *)confirmStr confirmBlock:(void (^)(BOOL, id))block;
+ (LGBaseAlertView* )showAlertwWithContent:(NSString *)contentStr WithHandle:(void (^)(BOOL isValue, id obj))block;
+ (LGBaseAlertView* )showAlertWithContent:(NSString *)contentStr  confirmBlock:(void (^)(BOOL is_value, id obj))block;
+ (LGBaseAlertView *)showDepositAlertwWithContent:(NSString *)contentStr WithHandle:(void (^)(BOOL isValue, id obj))block;
@end
