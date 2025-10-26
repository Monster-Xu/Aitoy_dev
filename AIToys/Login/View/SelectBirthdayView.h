//
//  SelectBirthdayView.h
//  AIToys
//
//  Created by qdkj on 2025/8/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectBirthdayView : UIView
@property (nonatomic, copy) void(^confirmBlock)(NSString *str,NSDate *selectDate);
@property (nonatomic, strong)NSDate *defalutDate;
-(void)show;
@end

NS_ASSUME_NONNULL_END
