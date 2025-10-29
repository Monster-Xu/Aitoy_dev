//
//  APIPortConfiguration.m
//  AIToys
//
//  Created by qdkj on 2025/8/20.
//

#import "APIPortConfiguration.h"

@implementation APIPortConfiguration

/// 所有接口请求的基础域名
+ (NSString *)baseURL {
    ///当前环境 1、测试  2、生产
//    NSInteger type = [[NSUserDefaults standardUserDefaults] integerForKey:KCURRENT_API_TYPE];
//    if (type == 2) {
//        return @"https://app.talenpalussaastest.com/";
//    } else{
//        return @"https://app.talenpalussaastest.com/";
//    }
    return @"https://app-pre.talenpalussaastest.com/";
}

/// 登录接口
+ (NSString *)getLoginUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/member/auth/login"];
}

/// 首页
+ (NSString *)getHomeDoolListUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/instance/page"];
}

/// 首页探索
+ (NSString *)getHomeExploreListUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/model/list"];
}

/// 首页Banner
+ (NSString *)getHomeBannerListUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/banner/list"];
}

/// 启动图
+ (NSString *)getSplashScreenUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/splash-screen/list"];
}

/// 手动添加设备列表
+ (NSString *)getDoolModelListUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/model/list"];
}

/// 请求公仔信息
+ (NSString *)getDoolModelGetUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/model/get-by-hardware"];
}

/// 删除公仔
+ (NSString *)getDoolDeleteUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/instance/delete"];
}

/// 公仔排序
+ (NSString *)getDoolSortUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/instance/sort"];
}

/// 创建app配置属性
+ (NSString *)getAppPropertyCreateUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-property/create"];
}

/// 获取app配置属性
+ (NSString *)getAppPropertyUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-property/page"];
}

/// 根据key获取app配置属性
+ (NSString *)getAppPropertyByKeyUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-property/get-by-key"];
}

+ (NSString *)getDeleteProPertUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-property/delete"];
}

/// 埋点上报接口
+ (NSString *)getEventLogCreateUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-event-log/create"];
}

/// 获取用户头像列表
+ (NSString *)getAppAvatarListUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-avatar/list"];
}

/// 上传用户头像
+ (NSString *)getAppAvatarUpdateUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-avatar/update"];
}

/// 获取用户头像
+ (NSString *)getAppAvatarUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-avatar/get"];
}

+ (NSString *)getdollListUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/model/asset/list-by-doll-model-id"];
}
#pragma mark - 故事相关接口

/// 创建故事
+ (NSString *)getCreateStoryUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/stories"];
}

/// 查询故事列表
+ (NSString *)getStoriesListUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/stories"];
}

/// 查询故事详情
+ (NSString *)getStoryDetailUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/stories/detail"];
}

/// 编辑故事
+ (NSString *)getUpdateStoryUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/stories/update"];
}

/// 编辑失败的故事（重新生成）
+ (NSString *)getUpdateFailedStoryUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/stories/update_fail"];
}

/// 删除故事
+ (NSString *)getDeleteStoryUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/stories/delete"];
}

/// 故事音频合成
+ (NSString *)getSynthesizeStoryUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/stories/synthesize"];
}

#pragma mark - 声音相关接口

/// 创建声音（开始克隆）
+ (NSString *)getCreateVoiceUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/voices/clone"];
}

/// 查询声音列表
+ (NSString *)getVoicesListUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/voices"];
}

/// 查询声音详情
+ (NSString *)getVoiceDetailUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/voices/detail"];
}

/// 编辑声音
+ (NSString *)getUpdateVoiceUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/voices/update"];
}

/// 删除声音
+ (NSString *)getDeleteVoiceUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/voices/delete"];
}

/// ⭐ 上传音频文件（用于声音克隆）
+ (NSString *)getUploadAudioUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/minimax/upload_audio"];
}

#pragma mark - 通用资源接口

/// 获取官方插画列表
+ (NSString *)getIllustrationsUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/illustrations"];
}

/// 获取官方音色列表
+ (NSString *)getOfficialVoicesUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/voices/official"];
}

/// 查询故事类型枚举
+ (NSString *)getStoryTypesUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/stories/types"];
}

/// 查询故事长度枚举
+ (NSString *)getStoryLengthsUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/stories/lengths"];
}

@end
