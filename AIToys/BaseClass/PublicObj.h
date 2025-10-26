//
//  PublicObj.h
//  www
//
//  Created by 乔不赖 on 2020/7/15.
//  Copyright © 2020 zhongchi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GradientType) {
    GradientFromTopToBottom,
    GradientFromLeftToRight,
    GradientFromLeftTopToRightBottom,
    GradientFromLeftBottomToRightTop
};

typedef NS_ENUM(NSInteger,AddStatusType) {
    AddStatusType_default = 0,
    AddStatusType_findWifi,
    AddStatusType_progress,
    AddStatusType_fail,
    AddStatusType_success,
};

typedef NS_ENUM(NSInteger, EmailType) {
    EmailType_regist = 0,//注册
    EmailType_forgetPwd,//忘记密码
    EmailType_change,//更换邮箱
    EmailType_modifyPwd,//修改密码
};


@interface PublicObj : NSObject

//字体size
extern CGSize QDSize(NSString* str, UIFont* font, CGSize size);

//设置placeholder颜色
+ (void)setTextFieldPlacholderColor:(UITextField *)textField color:(UIColor *)color;

//设置UIview几个角为切角
+ (void)makeCornerToView:(UIView *)view withFrame:(CGRect)frame withRadius:(CGFloat)radius position:(NSInteger )position;

// 创建一张渐变色图片
+ (UIImage *)createImageSize:(CGSize)imageSize gradientColors:(NSArray *)colors percentage:(NSArray *)percents gradientType:(GradientType)gradientType;

// 添加四边阴影效果
+ (void)addShadowToView:(UIView *)theView color:(UIColor *)theColor shadowRadius:(CGFloat)shadowRadius;

// 划线价格
+ (NSMutableAttributedString *)addLineToStr:(NSString *)string withColor:(UIColor *)theColor;

#pragma mark -遍历获取指定类型的属性 iOS 13 中部分方法属性不允许使用 valueForKey、setValue:forKey: 来获取或者设置私有属性
+ (UIView *)findViewWithClassName:(NSString *)className inView:(UIView *)view;

/**
 获取icon

 @return    icon
 */
+(UIImage *)getAppIcon;

/**
给字体设置间距
*/
+ (NSAttributedString *)setTitle:(NSString *)title WithSpace:(CGFloat)space withFont:(UIFont*)font;
/**
文件大小转换
*/
+(NSString *)getFileSize:(NSInteger)size;

/**
将数字转换成字母
*/
+(NSString *)converToAlphabet:(NSInteger)num;

/**
 判断字符串是否只含有数字
*/
+ (BOOL)validateNumber:(NSString*)number;

/**
 判断版本更新
*/
+ (BOOL)compareVesionWithServerVersion:(NSString *)version;

/**
 view转成image
*/
+ (UIImage*)imageWithUIView:(UIView*)view;

/**
 分段显示文字大小
*/
+ (void)labelAttributedString:(UILabel *)label text:(NSString *)text index:(NSInteger )index textSize1:(CGFloat)size1  textSize2:(CGFloat)size2;

/**
 判断对象是否为空
 @param object 传入的对象（包括NSNumber， NSString，NSDictionry等）
*/
+ (BOOL) isEmptyObject:(id)object;

///**
// 处理图片url
//*/
//+ (NSString *)handleLogo:(NSString *)logoPath;

/// 验证手机号码是否有效
/// @param mobilePhone 手机号码 字符串
+ (BOOL)verifyMobile:(NSString *)mobilePhone;

/// 验证手机号码是否有效
/// @param mobileNum 手机号码 字符串
+ (BOOL)validateContactNumber:(NSString *)mobileNum;

/// 验证身份证号码是否有效
/// @param identityCard 身份证号码
+ (BOOL)validateIdentityCard:(NSString *)identityCard;

/// 验证身邮箱是否有效
/// @param email 邮箱
+ (BOOL)validateEmail:(NSString *)email;

/// 验证护照是否有效
/// @param passport 护照
+ (BOOL)validatePassport:(NSString *)passport;

/// 验证汽车车牌号是否有效
/// @param licensePlate 汽车车牌号
+ (BOOL)validateLicensePlate:(NSString *)licensePlate;

/// 验证银行卡号是否有效
/// @param bankCard 银行卡号
+ (BOOL)validateBankCard:(NSString *)bankCard;

// 获取缓存文件的大小
+ ( float )readCacheSize;

// 清理缓存
+ (void)clearFile;

// 按钮置灰不可点击
+ (void)makeButtonUnEnable:(UIButton *)btn;

// 按钮恢复可点击
+ (void)makeButtonEnable:(UIButton *)btn;

// 获取当前页面
+ (UIViewController *)getCurrentViewController;

// 随机字符串
+ (NSString *)randomStringWithLength:(NSUInteger)length;
@end

NS_ASSUME_NONNULL_END
