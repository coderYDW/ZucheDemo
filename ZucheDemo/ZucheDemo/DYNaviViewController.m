//
//  DYNaviViewController.m
//  ZucheDemo
//
//  Created by Yangdongwu on 2017/7/7.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYNaviViewController.h"

@interface DYNaviViewController () <AMapNaviDriveViewDelegate,AMapNaviDriveManagerDelegate>

@property (nonatomic, strong) AMapNaviDriveManager *driveManager;
@property (nonatomic, strong) AMapNaviDriveView *driveView;
@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;

@end

@implementation DYNaviViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //开始和结束地点
    self.startPoint = [AMapNaviPoint locationWithLatitude:WZKGDA.latitude longitude:WZKGDA.longitude];
    self.endPoint = [AMapNaviPoint locationWithLatitude:SZBZ.latitude longitude:SZBZ.longitude];
    
    //创建driveManager
    if (self.driveManager == nil) {
        self.driveManager = [[AMapNaviDriveManager alloc] init];
        self.driveManager.delegate = self;
    }
    
    //创建driveView
    self.driveView = [[AMapNaviDriveView alloc] initWithFrame:self.view.bounds];
    self.driveView.delegate = self;
    [self.view addSubview:self.driveView];
    
    //关联driveManager和driveView
    [self.driveManager addDataRepresentative:self.driveView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.driveManager calculateDriveRouteWithStartPoints:@[self.startPoint]
                                                endPoints:@[self.endPoint]
                                                wayPoints:nil
                                          drivingStrategy:AMapNaviDrivingStrategySingleDefault];
    
}

/**
 *  发生错误时,会调用代理的此方法
 *
 *  @param error 错误信息
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error {
    
}

/**
 *  驾车路径规划成功后的回调函数
 */
- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager {
    
    [driveManager startEmulatorNavi];
//    [driveManager startGPSNavi];
    
}

/**
 *  驾车路径规划失败后的回调函数
 *
 *  @param error 错误信息,error.code参照AMapNaviCalcRouteState
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error {
    
}


@end
