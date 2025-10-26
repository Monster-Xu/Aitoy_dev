//
//  HomeToysListVC.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/25.
//

#import "BaseViewController.h"
#import "HomeDollModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeToysListVC : BaseViewController
@property(strong, nonatomic) NSMutableArray<HomeDollModel *> *diyDollList;
@property (nonatomic, assign) BOOL isEdit;//是否是编辑状态
@end

NS_ASSUME_NONNULL_END
