//
//  BottomPickerView.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BottomPickerViewSelectBlock)(NSInteger selectedIndex, NSString *selectedValue);

@interface BottomPickerView : UIView

/// 初始化方法
/// @param title 标题
/// @param options 选项数组
/// @param selectedIndex 当前选中的索引，-1表示未选中
/// @param selectBlock 选择回调
- (instancetype)initWithTitle:(NSString *)title
                      options:(NSArray<NSString *> *)options
                selectedIndex:(NSInteger)selectedIndex
                  selectBlock:(BottomPickerViewSelectBlock)selectBlock;

/// 显示选择器
- (void)show;

/// 隐藏选择器
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
