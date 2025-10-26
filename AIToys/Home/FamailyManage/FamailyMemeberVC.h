//
//  FamailyMemeberVC.h
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FamailyMemeberVC : BaseViewController
@property (nonatomic, strong) ThingSmartHomeModel *homeModel;
@property (nonatomic, strong)ThingSmartHomeMemberModel *memberModel;
@property (nonatomic, strong)ThingSmartHomeInvitationRecordModel *inviteModel;
@property(strong, nonatomic) ThingSmartHomeInvitation *smartHomeInvitation;
@end

NS_ASSUME_NONNULL_END
