//
//  VoiceManagementViewController.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//  Updated: 2025/10/16 - 集成骨架屏加载效果
//

#import "BaseViewController.h"
#import "VoiceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VoiceManagementViewController : BaseViewController

/// 声音列表数据源
@property (nonatomic, strong) NSMutableArray<VoiceModel *> *voiceList;

/// 是否正在加载中
@property (nonatomic, assign) BOOL isLoading;

/// 骨架屏显示的行数
@property (nonatomic, assign) NSInteger skeletonRowCount;

@end

NS_ASSUME_NONNULL_END
