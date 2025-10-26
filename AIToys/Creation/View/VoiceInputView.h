//
//  VoiceInputView.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VoiceInputState) {
    VoiceInputStateReady,      // 准备录音状态
    VoiceInputStateRecording,  // 录音中状态
    VoiceInputStateCompleted   // 录音完成状态
};

typedef void(^VoiceInputCompletionBlock)(NSString *recognizedText);
typedef void(^VoiceInputCancelBlock)(void);

@interface VoiceInputView : UIView

/// 初始化方法
/// @param completionBlock 语音识别完成回调
/// @param cancelBlock 取消回调
- (instancetype)initWithCompletionBlock:(VoiceInputCompletionBlock)completionBlock
                            cancelBlock:(VoiceInputCancelBlock)cancelBlock;

/// 显示语音输入界面
- (void)show;

/// 隐藏语音输入界面
- (void)dismiss;

/// 更新识别的文本内容
/// @param text 识别到的文本
- (void)updateRecognizedText:(NSString *)text;

/// 切换录音状态
/// @param state 新的状态
- (void)switchToState:(VoiceInputState)state;

@end

NS_ASSUME_NONNULL_END
