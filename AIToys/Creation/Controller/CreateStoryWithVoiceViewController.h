//
//  CreateStoryWithVoiceViewController.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CreateStoryWithVoiceViewController : BaseViewController

@property(nonatomic,assign)NSInteger  storyId;
@property(nonatomic,assign)BOOL isEditMode; // 是否为编辑模式

// 便利初始化方法
- (instancetype)initWithEditMode:(BOOL)editMode;

@end

NS_ASSUME_NONNULL_END
