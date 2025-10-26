//
//  DeviceAddCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "DeviceAddCell.h"


@implementation DeviceAddCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.addBtn setTitle:LocalString(@"添加") forState:0];
    self.progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 32.0f, 32.0f)];
    self.progressView.roundedCorners = YES;
    self.progressView.thicknessRatio = 0.1f;
    self.progressView.progressTintColor = mainColor;
    self.progressView.trackTintColor = UIColorFromRGBA(000000, 0.2);
    [self.containerView addSubview:self.progressView];
    self.loadingCircle.hidden = YES;
    self.loadingCircle.hidesWhenStopped= YES;
    self.loadingCircle.color= mainColor;
//    [self.loadingCircle startAnimating];
}

-(void)setType:(AddStatusType)type{
    switch (type) {
        case AddStatusType_findWifi:
            self.addBtn.hidden = YES;
            self.containerView.hidden = YES;
            self.addImgView.hidden = YES;
            self.statusBtn.hidden = YES;
            self.statusLabel.text = LocalString(@"正在寻找可用Wi-Fi...");
            self.statusLabel.textColor = UIColorFromRGBA(0x000000, 0.5);
            self.loadingCircle.hidden = NO;
            [self.loadingCircle startAnimating];
            break;
        case AddStatusType_progress:
            self.addBtn.hidden = YES;
            self.containerView.hidden = NO;
            self.addImgView.hidden = YES;
            self.statusBtn.hidden = YES;
            self.loadingCircle.hidden = YES;
            self.statusLabel.text = LocalString(@"设备添加中");
            self.statusLabel.textColor = UIColorFromRGBA(0x000000, 0.5);
            [self.loadingCircle stopAnimating];
            break;
            
        case AddStatusType_success:
            self.addBtn.hidden = YES;
            self.containerView.hidden = YES;
            self.addImgView.hidden = YES;
            self.statusBtn.hidden = NO;
            self.loadingCircle.hidden = YES;
            [self.statusBtn setImage:QD_IMG(@"add_edit") forState:0];
            self.statusBtn.userInteractionEnabled = YES;
            self.statusLabel.text = LocalString(@"设备已添加");
            self.statusLabel.textColor = UIColorFromRGBA(0x000000, 0.5);
            break;
        case AddStatusType_fail:
            self.addBtn.hidden = YES;
            self.containerView.hidden = YES;
            self.addImgView.hidden = YES;
            self.statusBtn.hidden = NO;
            self.loadingCircle.hidden = YES;
            [self.statusBtn setImage:QD_IMG(@"add_fail") forState:0];
            self.statusBtn.userInteractionEnabled = NO;
            self.statusLabel.text = LocalString(@"设备添加失败");
            self.statusLabel.textColor = UIColorFromRGB(0xFF4400);
            break;
            
        default:
            self.addBtn.hidden = NO;
            self.containerView.hidden = YES;
            self.addImgView.hidden = YES;
            self.statusBtn.hidden = YES;
            self.loadingCircle.hidden = YES;
            self.statusLabel.text = LocalString(@"设备待添加");
            self.statusLabel.textColor = UIColorFromRGBA(0x000000, 0.5);
            break;
    }
}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    self.progressView.progress = progress;
}


//添加设备
- (IBAction)addBtnClick:(UIButton *)sender {
    if (self.addBlock) {
        self.addBlock();
    }
}

//编辑设备名称
- (IBAction)editBtnClick:(id)sender {
    if(self.editBlock){
        self.editBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
