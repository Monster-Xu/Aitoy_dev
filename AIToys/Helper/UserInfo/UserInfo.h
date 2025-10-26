//
//  UserInfo.h
//  HelloBrother
//
//  Created by 乔不赖 on 2024/1/16.
//

#import <Foundation/Foundation.h>

#define kMyUser [UserInfo shared]

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo : NSObject
@property (nonatomic,copy) NSString *email;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *passWord;
@property (nonatomic,copy) NSString *phoneCode;
@property (nonatomic,copy) NSString *headPic;
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *mobile;

@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *accessToken;


+ (instancetype)shared;

+ (void)saveMyUser;

+ (void)clearMyUser;

+ (void)showLogin;
@end

NS_ASSUME_NONNULL_END
