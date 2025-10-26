//
//  CreateVoiceViewController.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/14.
//

#import "BaseViewController.h"
#import "VoiceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CreateVoiceViewController : BaseViewController

/// 编辑模式 - 传入已存在的音色数据进行编辑
@property (nonatomic, strong, nullable) VoiceModel *editingVoice;

/// 是否为编辑模式
@property (nonatomic, assign) BOOL isEditMode;

@end

NS_ASSUME_NONNULL_END
