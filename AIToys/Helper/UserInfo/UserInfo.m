//
//  UserInfo.m
//  HelloBrother
//
//  Created by 乔不赖 on 2024/1/16.
//

#import "UserInfo.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

static NSString * const MyUserKey = @"SingletonUserInfo";

static UserInfo *manager = nil;
static dispatch_once_t onceToken;

@implementation UserInfo
MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    //前边的是你想用的key，后边的是返回的key
    return @{@"Id" : @[@"id"],
             @"mobile" : @[@"mobile", @"phone"]};
}

    
+ (instancetype)shared {
    dispatch_once(&onceToken, ^{
        UserInfo *model = [UserInfo unarchiveMyUser];
        if (model) {
            manager = model;
        } else {
            manager = [[UserInfo alloc] init];
        }
    });
    return manager;
}

+ (void)saveMyUser {
    //归档黑名单
    [UserInfo mj_setupIgnoredCodingPropertyNames:^NSArray *{
        return @[@"acountType",@"domain"];
    }];
    //归档白名单
    //[UserInfo mj_setupAllowedPropertyNames:^NSArray *{
    //    return @[@"userId", @"sex"];
    //}];
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:kMyUser];
    [KUserDefaults setObject:myEncodedObject forKey:MyUserKey];
    [KUserDefaults synchronize];
}

+ (void)clearMyUser {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MyUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UserInfo attemptDealloc];
}

+ (void)showLogin{
    [UIApplication sharedApplication].keyWindow.rootViewController = [[MyNavigationController alloc]initWithRootViewController:[LoginViewController new]];
}

#pragma mark -
#pragma mark -- private method

+ (void)attemptDealloc {
    manager = nil;
    onceToken = 0;
}

+ (UserInfo *)unarchiveMyUser {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:MyUserKey];
    UserInfo *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return model;
}
    
+ (void)clearUserInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MyUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
