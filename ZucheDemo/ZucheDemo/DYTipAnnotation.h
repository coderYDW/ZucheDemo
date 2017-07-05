//
//  DYTipAnnotation.h
//  ZucheDemo
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DYTipAnnotation : NSObject <MAAnnotation>

- (instancetype)initWithTip:(AMapTip *)tip;

@property (nonatomic, readonly, strong) AMapTip *tip;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

/*!
 @brief 获取annotation标题
 @return 返回annotation的标题信息
 */
- (NSString *)title;

/*!
 @brief 获取annotation副标题
 @return 返回annotation的副标题信息
 */
- (NSString *)subtitle;

@end
