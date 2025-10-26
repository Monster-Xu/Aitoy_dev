//
//  AddToysGuideVC.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/22.
//

#import "AddToysGuideVC.h"
#import "ATFontManager.h"

@interface AddToysGuideVC ()

@end

@implementation AddToysGuideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view.
}

-(void)setupUI{
    self.view.backgroundColor = UIColorFromRGBA(000000, 0.5);
    self.alertView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 470);
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 24;
    self.alertView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *topImgView = [[UIImageView alloc] init];
    topImgView.contentMode = UIViewContentModeScaleToFill;
    topImgView.image = QD_IMG(@"toys_guide_bg");
    [self.alertView addSubview:topImgView];
    [topImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.alertView);
    }];
    
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setImage:[UIImage imageNamed:@"close_layer"] forState:0];
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(self.alertView);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(50);
    }];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = LocalString(@"将 Talens 放在 Talenpal 播放器上并等待一会儿，然后 Talens 就会出现。");
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.font = [ATFontManager boldSystemFontOfSize:20];
    contentLabel.textColor = UIColorFromRGBA(000000, 0.9);
    contentLabel.numberOfLines = 0;
    [self.alertView addSubview:contentLabel];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topImgView.mas_bottom).offset(25);
        make.left.equalTo(self.alertView).offset(24);
        make.right.equalTo(self.alertView).offset(-24);
    }];
    
    UIButton *sureBtn = [[UIButton alloc] init];
    [sureBtn setTitle:LocalString(@"确定") forState:0];
    sureBtn.titleLabel.font = [ATFontManager boldSystemFontOfSize:15];
    [sureBtn setTitleColor:UIColor.whiteColor forState:0];
    sureBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    sureBtn.backgroundColor = mainColor;
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    sureBtn.layer.cornerRadius = 24;
    [self.alertView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentLabel.mas_bottom).offset(25);
        make.height.mas_equalTo(48);
        make.left.equalTo(self.alertView).offset(24);
        make.right.equalTo(self.alertView).offset(-24);
        make.bottom.equalTo(self.alertView).offset(-25);
    }];
    
}


//关闭
-(void)close{
    [self dismiss:0];
}

//确定
-(void)sureBtnClick{
    if (self.sureBlock) {
        self.sureBlock();
    }
    [self dismiss:0];
}

//出现的动画
- (void)showView {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.transform = CGAffineTransformMakeTranslation(0, -self.alertView.height);
    } completion:^(BOOL finished) {
        
    }];
}

//消失的动画
- (void)dismiss:(NSInteger)handle {
    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self dismiss:0];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
