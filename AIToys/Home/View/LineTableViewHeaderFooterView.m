//
//  LineTableViewHeaderFooterView.m
//  AIToys
//
//  Created by qdkj on 2025/8/5.
//

#import "LineTableViewHeaderFooterView.h"
#import "ATFontManager.h"

@implementation LineTableViewHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        UIView *backView = UIView.new;
        backView.frame = self.bounds;
        self.backView = backView;
        [self addSubview:backView];
        
        UILabel *lab = [[UILabel alloc] init];
        lab.frame = CGRectMake(16, 10, 100, 50);
        lab.font = [ATFontManager systemFontOfSize:16 weight:600];
        lab.textColor = [UIColor blackColor];
        lab.text = @"  ";
        self.titleLab = lab;
        [self addSubview:lab];
    }
    return self;
}

@end
