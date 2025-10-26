//
//  ComponentLicenseModel.h
//  AIToys
//
//  Created by qdkj on 2025/7/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ComponentLicenseModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *compentUrl;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *licence;
@property (nonatomic, copy) NSString *licenceUrl;
@property (nonatomic, copy) NSString *modify;
@end

NS_ASSUME_NONNULL_END
