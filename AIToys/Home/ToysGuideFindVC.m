//
//  ToysGuideFindVC.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/25.
//

#import "ToysGuideFindVC.h"
#import "ATFontManager.h"

@interface ToysGuideFindVC ()

@end

@implementation ToysGuideFindVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI{
    self.view.backgroundColor = UIColorFromRGBA(000000, 0.5);
    self.alertView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 370);
    self.alertView.layer.cornerRadius = 24;
    self.alertView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = LocalString(@"发现新公仔");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [ATFontManager systemFontOfSize:24];
    titleLabel.textColor = UIColorFromRGBA(000000, 0.9);
    [self.alertView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.alertView).offset(20);
        make.left.equalTo(self.alertView).offset(20);
        make.height.mas_equalTo(30);
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
    
    UIImageView *topImgView = [[UIImageView alloc] init];
//    topImgView.contentMode = UIViewContentModeScaleToFill;
    [topImgView sd_setImageWithURL:[NSURL URLWithString:self.model.coverImg] placeholderImage: QD_IMG(@"toys_find_preview")];
//    topImgView.image = QD_IMG(@"toys_find_preview");
    [self.alertView addSubview:topImgView];
    [topImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(180, 180));
        make.centerX.equalTo(self.alertView);
    }];
    
    UIButton *sureBtn = [[UIButton alloc] init];
    [sureBtn setTitle:LocalString(@"知道了") forState:0];
    sureBtn.titleLabel.font = [ATFontManager boldSystemFontOfSize:15];
    [sureBtn setTitleColor:mainColor forState:0];
    sureBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    sureBtn.backgroundColor = UIColor.whiteColor;
    sureBtn.layer.borderColor = mainColor.CGColor;
    sureBtn.layer.borderWidth = 1;
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    sureBtn.layer.cornerRadius = 24;
    [self.alertView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topImgView.mas_bottom).offset(35);
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
