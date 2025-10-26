//
//  LGGuideCollectionViewCell.m
//  GasClient
//
//  Created by KWOK on 2021/4/1.
//

#import "LGGuideCollectionViewCell.h"

@interface LGGuideCollectionViewCell ()

@end

@implementation LGGuideCollectionViewCell
- (UIImageView *)imgView
{
    if(!_imgView){
        _imgView = [UIImageView new];
        [self.contentView addSubview:_imgView];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.edges.mas_equalTo(self.contentView);
        }];
    }
    return _imgView;
}
@end
