//
//  MineItemModel.h
//  AIToys
//
//  Created by 乔不赖 on 2025/7/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MineItemModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *toVC;
@property (nonatomic, assign) BOOL isOn;
@end

NS_ASSUME_NONNULL_END
