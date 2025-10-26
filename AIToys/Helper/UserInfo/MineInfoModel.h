//
//  MineInfoModel.h
//  HelloBrother
//
//  Created by 乔不赖 on 2024/1/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MineInfoModel : NSObject
@property (nonatomic ,copy) NSString *qq_nickname;
@property (nonatomic ,copy) NSString *qq_openid;
@property (nonatomic ,copy) NSString *appid;
@property (nonatomic ,copy) NSString *birthday;
@property (nonatomic ,copy) NSString *sheng;
@property (nonatomic ,copy) NSString *ctime;
@property (nonatomic ,copy) NSString *tel;
@property (nonatomic ,copy) NSString *shi;
@property (nonatomic ,copy) NSString *wx_openid;
@property (nonatomic ,copy) NSString *wb_nickname;
@property (nonatomic ,copy) NSString *referrer_tel;
@property (nonatomic ,copy) NSString *qq_headimgurl;
@property (nonatomic ,copy) NSString *dl_zt;
@property (nonatomic ,copy) NSString *check_in;
@property (nonatomic ,copy) NSString *qu;
@property (nonatomic ,copy) NSString *signature;
@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSString *wb_headimgurl;
@property (nonatomic ,copy) NSString *wx_headimgurl;
@property (nonatomic ,copy) NSString *ID;
@property (nonatomic ,copy) NSString *appsecret;
@property (nonatomic ,copy) NSString *pic;
@property (nonatomic ,copy) NSString *level_credit;
@property (nonatomic ,copy) NSString *label;
@property (nonatomic ,copy) NSString *gender;
@property (nonatomic ,copy) NSString *wb_openid;
@property (nonatomic ,copy) NSString *check_time;
@property (nonatomic ,copy) NSString *password;
@property (nonatomic ,copy) NSString *wx_nickname;
@property (nonatomic ,copy) NSString *passwords;
@property (nonatomic ,copy) NSString *integral;
@property (nonatomic ,copy) NSString *notused_volume;
@property (nonatomic ,copy) NSString *used_volume;
@property (nonatomic ,copy) NSString *be_overdue_volume;
@property (nonatomic ,copy) NSString *background;
@property (nonatomic ,copy) NSString *driver_type;
@property (nonatomic ,copy) NSString *controller_type;
@property (nonatomic ,copy) NSString *authentication_status;//0：未认证，1：个人认证，2：企业认证

@end

NS_ASSUME_NONNULL_END
