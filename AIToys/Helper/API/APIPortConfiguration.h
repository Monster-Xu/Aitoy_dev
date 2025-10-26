//
//  APIPortConfiguration.h
//  AIToys
//
//  Created by qdkj on 2025/8/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIPortConfiguration : NSObject

/// 所有接口请求的基础域名
+ (NSString *)baseURL;
/// 登录接口
+ (NSString *)getLoginUrl;

/// 首页
+ (NSString *)getHomeDoolListUrl;

/// 首页探索
+ (NSString *)getHomeExploreListUrl;

/// 首页Banner
+ (NSString *)getHomeBannerListUrl;
/// 启动图
+ (NSString *)getSplashScreenUrl;

/// 手动添加设备列表
+ (NSString *)getDoolModelListUrl;

/// 请求公仔信息
+ (NSString *)getDoolModelGetUrl;

/// 删除公仔
+ (NSString *)getDoolDeleteUrl;

/// 公仔排序
+ (NSString *)getDoolSortUrl;

/// 创建app配置属性
+ (NSString *)getAppPropertyCreateUrl;

/// 获取app配置属性
+ (NSString *)getAppPropertyUrl;

//删除APP配置属性
+(NSString *)getDeleteProPertUrl;
/// 根据key获取app配置属性
+ (NSString *)getAppPropertyByKeyUrl;

/// 埋点上报接口
+ (NSString *)getEventLogCreateUrl;

/// 获取用户头像列表
+ (NSString *)getAppAvatarListUrl;

/// 上传用户头像
+ (NSString *)getAppAvatarUpdateUrl;

/// 获取用户头像
+ (NSString *)getAppAvatarUrl;
//获取创意公仔信息
+ (NSString *)getdollListUrl;

#pragma mark - 故事相关接口
/// 创建故事
+ (NSString *)getCreateStoryUrl;

/// 查询故事列表
+ (NSString *)getStoriesListUrl;

/// 查询故事详情
+ (NSString *)getStoryDetailUrl;

/// 编辑故事
+ (NSString *)getUpdateStoryUrl;

/// 删除故事
+ (NSString *)getDeleteStoryUrl;

/// 故事音频合成
+ (NSString *)getSynthesizeStoryUrl;

#pragma mark - 声音相关接口

/// 创建声音（开始克隆）
+ (NSString *)getCreateVoiceUrl;

/// 查询声音列表
+ (NSString *)getVoicesListUrl;

/// 查询声音详情
+ (NSString *)getVoiceDetailUrl;

/// 编辑声音
+ (NSString *)getUpdateVoiceUrl;

/// 删除声音
+ (NSString *)getDeleteVoiceUrl;

/// ⭐ 上传音频文件
+ (NSString *)getUploadAudioUrl;

#pragma mark - 通用资源接口

/// 获取官方插画列表
+ (NSString *)getIllustrationsUrl;

/// 获取官方音色列表
+ (NSString *)getOfficialVoicesUrl;


@end

NS_ASSUME_NONNULL_END
