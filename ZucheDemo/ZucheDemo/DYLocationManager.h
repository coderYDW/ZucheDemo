//
//  DYLocationManager.h
//  ZucheDemo
//
//  Created by mac on 2017/7/3.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DYLocationManager : NSObject


@property (nonatomic, strong) CLLocation *userLocation; //!< 定位地址

@property (nonatomic, copy) void (^updateHandler)(CLLocation *location); //!< 定位回调


+ (instancetype)sharedManager;

/**
 开始定位
 */
- (void)startSerialLocation;

/**
 停止定位
 */
- (void)stopSerialLocation;


@end
