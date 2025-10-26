//
//  StoryBoundDoll.h
//  StoryAPI
//
//  Created on 2025-10-15.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface StoryBoundDoll : NSObject <YYModel>

@property (nonatomic, assign) NSInteger dollId;
@property (nonatomic, assign) NSInteger dollModelId;
@property (nonatomic, copy) NSString *customName;
@property (nonatomic, copy, nullable) NSString *dollModelType;
@property (nonatomic, copy, nullable) NSString *bindTime;
@property (nonatomic, assign) NSInteger sortOrder;

@end

NS_ASSUME_NONNULL_END
