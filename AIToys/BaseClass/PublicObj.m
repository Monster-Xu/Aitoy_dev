//
//  PublicObj.m
//  www
//
//  Created by 乔不赖 on 2020/7/15.
//  Copyright © 2020 zhongchi. All rights reserved.
//

#import "PublicObj.h"
#import "ATFontManager.h"

@implementation PublicObj

/**
 *文字+英文/数字混合计算会有误差
 */
CGSize QDSize(NSString* str, UIFont* font, CGSize size){
    if(!str || !str.length)return CGSizeZero;
    if(!size.width || !size.height){
        return [str sizeWithAttributes:@{NSFontAttributeName:font}];
    }
    return [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}

//设置placeholder颜色
+ (void)setTextFieldPlacholderColor:(UITextField *)textField color:(UIColor *)color{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:textField.font}];
    textField.attributedPlaceholder = attrString;
}

//设置UIview几个角为切角
+ (void)makeCornerToView:(UIView *)view withFrame:(CGRect)frame withRadius:(CGFloat)radius position:(NSInteger )position{
    UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    if (position == 1) {
        //上面两个切角
        corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    }else if (position == 2){
        //下面两个切角
        corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    }else if (position == 3){
        //左边两个切角
        corners = UIRectCornerTopLeft | UIRectCornerBottomLeft;
    }else if (position == 4){
        //右边两个切角
        corners = UIRectCornerTopRight | UIRectCornerBottomRight;
    }else if (position == 5){
        //左上右下两个切角
        corners = UIRectCornerTopLeft | UIRectCornerBottomRight;
    }else{
        corners = UIRectCornerTopLeft | UIRectCornerTopRight|UIRectCornerBottomLeft | UIRectCornerBottomRight;
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

// 创建一张渐变色图片
+ (UIImage *)createImageSize:(CGSize)imageSize gradientColors:(NSArray *)colors percentage:(NSArray *)percents gradientType:(GradientType)gradientType {
    
    NSAssert(percents.count <= 5, @"输入颜色数量过多，如果需求数量过大，请修改locations[]数组的个数");
    
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    
    //    NSUInteger capacity = percents.count;
    //    CGFloat locations[capacity];
    CGFloat locations[5];
    for (int i = 0; i < percents.count; i++) {
        locations[i] = [percents[i] floatValue];
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, locations);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case GradientFromTopToBottom:
            start = CGPointMake(imageSize.width/2, 0.0);
            end = CGPointMake(imageSize.width/2, imageSize.height);
            break;
        case GradientFromLeftToRight:
            start = CGPointMake(0.0, imageSize.height/2);
            end = CGPointMake(imageSize.width, imageSize.height/2);
            break;
        case GradientFromLeftTopToRightBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(imageSize.width, imageSize.height);
            break;
        case GradientFromLeftBottomToRightTop:
            start = CGPointMake(0.0, imageSize.height);
            end = CGPointMake(imageSize.width, 0.0);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

/// 添加四边阴影效果
+ (void)addShadowToView:(UIView *)theView color:(UIColor *)theColor shadowRadius:(CGFloat)shadowRadius {
    theView.layer.masksToBounds = NO;
    // 阴影颜色
    theView.layer.shadowColor = theColor.CGColor;
    // 阴影偏移，默认(0, -3)
    theView.layer.shadowOffset = CGSizeMake(0,0);
    // 阴影透明度，默认0
    theView.layer.shadowOpacity = 0.5;
    // 阴影半径，默认3
    theView.layer.shadowRadius = shadowRadius>0 ? shadowRadius : 3;
}

//添加下划线
+ (NSMutableAttributedString *)addLineToStr:(NSString *)string withColor:(UIColor *)theColor{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    [str addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, str.length)];
    
    [str addAttribute:NSForegroundColorAttributeName value:theColor range:NSMakeRange(0, str.length)];
    return str;
}

#pragma mark -遍历获取指定类型的属性 iOS 13 中部分方法属性不允许使用 valueForKey、setValue:forKey: 来获取或者设置私有属性
+ (UIView *)findViewWithClassName:(NSString *)className inView:(UIView *)view{
    Class specificView = NSClassFromString(className);
    if ([view isKindOfClass:specificView]) {
        return view;
    }
 
    if (view.subviews.count > 0) {
        for (UIView *subView in view.subviews) {
            UIView *targetView = [self findViewWithClassName:className inView:subView];
            if (targetView != nil) {
                return targetView;
            }
        }
    }
    
    return nil;
}

#pragma mark - 获取AppIcon
+(UIImage *)getAppIcon {
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    UIImage *img= [UIImage imageNamed:icon];
    return img;
}

#pragma mark - 给字体设置间距
+ (NSAttributedString *)setTitle:(NSString *)title WithSpace:(CGFloat)space withFont:(UIFont*)font{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
    paragraphStyle.hyphenationFactor=1.0;
    [paragraphStyle setLineSpacing:space];
    
    NSDictionary*dic =@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle,NSKernAttributeName:@1.0f};
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc]initWithString:title attributes:dic];
    return attributeStr;
}

/**
文件大小转换
*/
+(NSString *)getFileSize:(NSInteger)size{
    NSString *sizeStr;
    if (size < 1024) {
        sizeStr = [NSString stringWithFormat:@"%ldB",(long)size];
    }else {
        size = size/1024;
        if (size < 1024){
            sizeStr = [NSString stringWithFormat:@"%ldKB",(long)size];
        }else if (size< 1024*1024){
            sizeStr = [NSString stringWithFormat:@"%.2fMB",size/1024.0];
        }else if (size < 1024*1024*1024){
            sizeStr = [NSString stringWithFormat:@"%.2fG",size/( 1024.0 *1024.0)];
        }
    }
    return sizeStr;
}

/**
将数字转换成字母
*/
+(NSString *)converToAlphabet:(NSInteger)num{
    int temp = [[NSString stringWithFormat:@"%ld",(long)num] intValue];
    NSString *b_String  = [NSString stringWithFormat:@"%c",temp+64];
    return b_String;
}

/**
 判断字符串是否只含有数字
*/
+ (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

+ (BOOL)compareVesionWithServerVersion:(NSString *)version{
    
    NSArray *versionArray = [version componentsSeparatedByString:@"."];//服务器返回版
    
    NSArray *currentVesionArray = [[UIApplication sharedApplication].appVersion componentsSeparatedByString:@"."];//当前版本
    
    NSInteger a = (versionArray.count> currentVesionArray.count)?currentVesionArray.count : versionArray.count;
    for (int i = 0; i< a; i++) {
        NSInteger a = [[versionArray objectAtIndex:i] integerValue];
        NSInteger b = [[currentVesionArray objectAtIndex:i] integerValue];
        if (a > b) {
            NSLog(@"有新版本");
            return YES;
        }else if(a < b){
            return NO;
        }
    }
    return NO;
}

/**
 view转成image
*/
+ (UIImage*)imageWithUIView:(UIView*)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

/**
 分段显示文字大小
*/
+ (void)labelAttributedString:(UILabel *)label text:(NSString *)text index:(NSInteger )index textSize1:(CGFloat)size1  textSize2:(CGFloat)size2{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:size1] range:NSMakeRange(0, index)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size2] range:NSMakeRange(index, text.length-index)];
    label.attributedText = str;
}

//+ (NSString *)handleLogo:(NSString *)logoPath {
//    if (strIsEmpty(logoPath)) {
//        return @"";
//    } else {
//        if ([logoPath containsString:@"http"]) {
//            return logoPath;
//        } else {
//            return [NSString stringWithFormat:@"%@%@",PATH,logoPath];
//        }
//    }
//}

// 判断对象是否为空
/// @param object 传入的对象（包括NSNumber， NSString，NSDictionry等）
+ (BOOL) isEmptyObject:(id)object

{

    if (object == nil || [object isEqual:[NSNull class]]) {

        return YES;

    }else if ([object isKindOfClass:[NSNull class]])

    {

        if ([object isEqualToString:@""]) {

            return YES;

        }else

        {

            return NO;

        }

    }else if ([object isKindOfClass:[NSNumber class]])

    {

        if ([object isEqualToNumber:@0]) {

            return YES;

        }else

        {

            return NO;

        }

    }else if ([object isKindOfClass:[NSString class]])
    {
        NSString *str = (NSString *)object;
        str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([str isEqualToString:@""]) {

            return YES;

        }else

        {

            return NO;

        }
    }

    return NO;

}

+ (BOOL)verifyMobile:(NSString *)mobilePhone{
    NSString *express = @"^0{0,1}(13[0-9]|15[0-9]|16[0-9]|18[0-9]|14[0-9])[0-9]{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF matches %@", express];
    BOOL boo = [pred evaluateWithObject:mobilePhone]; // 1= 成功 YES
    return boo;
}

+ (BOOL)validateContactNumber:(NSString *)mobileNum{
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[0-9]|9[278])\\d)\\d{7}$";
    
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|4[567]|5[256]|6[6]|7[0-9]|8[56])\\d{8}$";
    
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,177,180,189
     22         */
    NSString * CT = @"^1((33|53|77|8[09])[0-9]|349)\\d{7}$";
    
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestPHS = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if(([regextestmobile evaluateWithObject:mobileNum] == YES)
       || ([regextestcm evaluateWithObject:mobileNum] == YES)
       || ([regextestct evaluateWithObject:mobileNum] == YES)
       || ([regextestcu evaluateWithObject:mobileNum] == YES)
       || ([regextestPHS evaluateWithObject:mobileNum] == YES)){
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)validateIdentityCard:(NSString *)identityCard
{
    NSString *regex = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([regextestmobile evaluateWithObject:identityCard] == YES) {
        return YES;
    }else{
        return NO;
    }
}

/// 验证身邮箱是否有效
/// @param email 邮箱
+ (BOOL)validateEmail:(NSString *)email
{
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([regextestmobile evaluateWithObject:email] == YES) {
        return YES;
    }else{
        return NO;
    }
}

/// 验证护照是否有效
/// @param passport 护照
+ (BOOL)validatePassport:(NSString *)passport
{
    /** 第一位是字母，后面都是数字
     
     P:P开头的是因公普通护照
     D:外交护照是D开头
     E: 有电子芯片的普通护照为“E”字开头，
     S: 后接8位阿拉伯数字公务护照
     G:因私护照G开头
     14：
     15：
     
     H:香港特区护照和香港公民所持回乡卡H开头,后接10位数字
     M:澳门特区护照和澳门公民所持回乡卡M开头,后接10位数字
     */
    NSString *regex = @"^1[45][0-9]{7}|([P|p|S|s]\\d{7})|([S|s|G|g]\\d{8})|([Gg|Tt|Ss|Ll|Qq|Dd|Aa|Ff]\\d{8})|([H|h|M|m]\\d{8，10})$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([regextestmobile evaluateWithObject:passport] == YES) {
        return YES;
    }else{
        return NO;
    }
}

/// 验证汽车车牌号是否有效
/// @param licensePlate 汽车车牌号
+ (BOOL)validateLicensePlate:(NSString *)licensePlate
{
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", carRegex];
    
    if ([regextestmobile evaluateWithObject:licensePlate] == YES) {
        return YES;
    }else{
        return NO;
    }
}

/// 验证银行卡号是否有效
/// @param bankCard 银行卡号
+ (BOOL)validateBankCard:(NSString *)bankCard
{
    NSString *regex = @"^(\\d{15,30})";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([regextestmobile evaluateWithObject:bankCard] == YES) {
        return YES;
    }else{
        return NO;
    }
}


// 获取缓存文件的大小
+ ( float )readCacheSize
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) firstObject];
    
    NSFileManager * manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath :cachePath]) return 0 ;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :cachePath] objectEnumerator];
    
    NSString * fileName;
    
    long long folderSize = 0 ;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil )
    {
        //获取文件全路径
        NSString * fileAbsolutePath = [cachePath stringByAppendingPathComponent :fileName];
        
        CGFloat fileSize = 0;
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath :fileAbsolutePath])
        {
            fileSize =  [[fileManager attributesOfItemAtPath :fileAbsolutePath error : nil] fileSize];
        }
        
        folderSize += fileSize;
        
    }
    
    return folderSize/( 1024.0 * 1024.0);
}



// 清理缓存
+ (void)clearFile
{
    NSString * cachePath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES ) firstObject];
    
    NSArray * files = [[NSFileManager defaultManager ] subpathsAtPath :cachePath];
    
    //NSLog ( @"cachpath = %@" , cachePath);
    
    for ( NSString * p in files)
    {
        
        NSError * error = nil ;
        
        //获取文件全路径
        NSString * fileAbsolutePath = [cachePath stringByAppendingPathComponent :p];
        
        if ([[NSFileManager defaultManager ] fileExistsAtPath :fileAbsolutePath])
        {
            [[NSFileManager defaultManager ] removeItemAtPath :fileAbsolutePath error :&error];
        }
    }
}

// 按钮置灰不可点击
+ (void)makeButtonUnEnable:(UIButton *)btn{
    btn.userInteractionEnabled = NO;
    [btn setBackgroundColor:unEnableColor];
}

// 按钮恢复可点击
+ (void)makeButtonEnable:(UIButton *)btn{
    btn.userInteractionEnabled = YES;
    [btn setBackgroundColor:mainColor];
}

// 获取当前页面
+ (UIViewController *)getCurrentViewController
{
    
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController* currentViewController = window.rootViewController;
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController* navigationController = (UINavigationController* )currentViewController;
            currentViewController = [navigationController.childViewControllers lastObject];
            
        } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController* tabBarController = (UITabBarController* )currentViewController;
            currentViewController = tabBarController.selectedViewController;
        } else {
            
            NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
            if (childViewControllerCount > 0) {
                
                currentViewController = currentViewController.childViewControllers.lastObject;
                
                return currentViewController;
            } else {
                
                return currentViewController;
            }
        }
        
    }
    return currentViewController;
}

// 随机字符串
+ (NSString *)randomStringWithLength:(NSUInteger)length {
    if (length < 10) length = 10; // 强制最小10位
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        uint32_t randomIndex = arc4random_uniform((uint32_t)[letters length]);
        unichar randomChar = [letters characterAtIndex:randomIndex];
        [randomString appendFormat:@"%C", randomChar];
    }
    
    return [randomString copy];
}
@end
