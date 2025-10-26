//
//  ExitView.h
//  www
//
//  Created by 乔不赖 on 2020/7/18.
//  Copyright © 2020 zhongchi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^sureBtnBlock)(void);
NS_ASSUME_NONNULL_BEGIN

@interface ExitView : UIView
@property (nonatomic,copy)sureBtnBlock sureBlock;
-(void)show;
@end

NS_ASSUME_NONNULL_END
