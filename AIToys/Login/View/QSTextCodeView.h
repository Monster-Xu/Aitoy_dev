//
//  QSTextCodeView.h
//  AIToys
//
//  Created by qdkj on 2025/6/19.
//

#import <UIKit/UIKit.h>
 
NS_ASSUME_NONNULL_BEGIN
typedef void (^ResultBlock)(NSString *str , NSDictionary *dic,BOOL isOK);
@interface QSTextCodeView : UIView
- (instancetype)initWithFrame:(CGRect)frame;
@property (nonatomic, assign) NSInteger fieldCount;
@property (nonatomic, copy) ResultBlock resultBlock;
- (void)becomeFirstResponder;
@end
 
@class UITextFieldAddDel;
@protocol TextFieldDelegate <NSObject>
- (void)textFieldDelete:(UITextFieldAddDel *)textField;
@end
 
@interface UITextFieldAddDel : UITextField
@property (nonatomic, assign) id <TextFieldDelegate> delDelegate;
@end
 
NS_ASSUME_NONNULL_END

