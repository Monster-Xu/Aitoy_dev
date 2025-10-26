//
//  HomeToysItem.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/21.
//

#import "HomeToysItem.h"

@implementation HomeToysItem

- (void)awakeFromNib {
    [super awakeFromNib];
    self.topLeftTitleLabel.text = LocalString(@"DIY公仔");
    self.storyNamLabel.text = LocalString(@"故事");
}

-(void)setIndex:(NSInteger)index{
    _index = index;
    self.rankLabel.text = [NSString stringWithFormat:@"%li",index + 1];
}

-(void)setIsEdit:(BOOL)isEdit{
    _isEdit = isEdit;
    [self starAnimation:isEdit];
    if(isEdit){
        self.rankView.hidden = YES;
        self.chooseImgView.hidden = NO;
    }else{
        self.rankView.hidden = NO;
        self.chooseImgView.hidden = YES;
    }
}

-(void)setIsSel:(BOOL)isSel{
    _isSel = isSel;
    if(isSel){
        self.chooseImgView.highlighted = YES;
    }else{
        self.chooseImgView.highlighted = NO;
    }
}

-(void)setModel:(HomeDollModel *)model{
    _model = model;
    self.topLeftView.hidden = ![model.dollModel.type isEqualToString:@"creative"];
    self.nameLabel.text = model.dollModel.name;
    [self.bgImgView sd_setImageWithURL:[NSURL URLWithString:model.dollModel.backgroundImg]];
    [self.toysImgView sd_setImageWithURL:[NSURL URLWithString:model.dollModel.coverImg]];
    self.storyNumLabel.text = [NSString stringWithFormat:@"%ld",(long)model.totalStoryNum];
    NSInteger hrs = model.totalStoryDuration / 3600;
    NSInteger mins = model.totalStoryDuration % 3600 /60;
    NSInteger s = model.totalStoryDuration % 60;
    NSString *timeStr = @"";
    if(hrs > 0){
        timeStr = [NSString stringWithFormat:@"%ld h ",(long)hrs];
    }
    if (mins > 0){
        timeStr = [timeStr stringByAppendingFormat:@"%ld min ",(long)mins];
    }
    if (s > 0){
        timeStr = [timeStr stringByAppendingFormat:@"%ld s ",(long)s];
    }
    if(timeStr.length == 0)
    {
        timeStr = @"0 s";
    }
    self.timeNumLabel.text = [NSString stringWithFormat:@"%@",timeStr];
}

-(void)starAnimation:(BOOL)animaiton
{
    if (animaiton) {
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //抖动的话添加一个旋转角度给他就好
        basicAnimation.fromValue = @(-M_PI_4/30);
        basicAnimation.toValue = @(M_PI_4/30);
        basicAnimation.duration = 0.15;
        basicAnimation.repeatCount = MAXFLOAT;
        basicAnimation.autoreverses = YES;
        [self.layer addAnimation:basicAnimation forKey:[NSString stringWithFormat:@"%li",(long)index + 1]];

    }else{
        [self.layer removeAllAnimations];
    }
    
}


@end
