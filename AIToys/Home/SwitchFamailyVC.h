//
//  SwitchFamailyVC.h
//  AIToys
//
//  Created by qdkj on 2025/6/26.
//

#import "PresentAlertVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SwitchFamailyVC : PresentAlertVC
@property(strong, nonatomic) NSArray<ThingSmartHomeModel *> *homeList;
@property(strong, nonatomic) ThingSmartHome *currentHome;
@property (nonatomic, copy) void(^sureBlock)(ThingSmartHomeModel *model);
@property (nonatomic, copy) void(^managerBlock)(void);
@end

NS_ASSUME_NONNULL_END
