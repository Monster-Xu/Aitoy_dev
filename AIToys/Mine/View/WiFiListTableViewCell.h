//
//  WiFiListTableViewCell.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WiFiListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *wifiNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property(nonatomic,strong)NSDictionary * dateDic;
@property (nonatomic, copy) void(^clickItemBlock)(void);
@end

NS_ASSUME_NONNULL_END
