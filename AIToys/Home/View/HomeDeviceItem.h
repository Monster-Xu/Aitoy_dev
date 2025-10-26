//
//  HomeDeviceItem.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeDeviceItem : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *onlineImgview;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;
@property (weak, nonatomic) IBOutlet UIView *batteryView;

@property (weak, nonatomic) IBOutlet UIImageView *batteryImgView;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UIView *rankView;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chooseImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrail;


@property (nonatomic, strong) ThingSmartDeviceModel *model;
@property(nonatomic, assign) BOOL isEdit;
@property(nonatomic, assign) BOOL isSel;
@property(nonatomic, assign) NSInteger index;

-(void)starAnimation:(BOOL)animaiton;
@end

NS_ASSUME_NONNULL_END
