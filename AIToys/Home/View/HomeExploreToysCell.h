//
//  HomeExploreToysCell.h
//  AIToys
//
//  Created by qdkj on 2025/6/26.
//

#import <UIKit/UIKit.h>
#import "HomeDollModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeExploreToysCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *horsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyLab;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;

@property (weak, nonatomic) IBOutlet UILabel *minutesLabel;
@property (weak, nonatomic) IBOutlet UILabel *minNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sLabel;
@property (weak, nonatomic) IBOutlet UILabel *sNamelabel;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (nonatomic, copy) void(^playBlock)(void);
@property (nonatomic, strong) FindDollModel *model;
@end

NS_ASSUME_NONNULL_END
