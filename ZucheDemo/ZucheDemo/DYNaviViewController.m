//
//  DYNaviViewController.m
//  ZucheDemo
//
//  Created by Yangdongwu on 2017/7/7.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYNaviViewController.h"
#import "SpeechSynthesizer.h"
#import "DYMoreMenuView.h"

#define SPEECH 0

@interface DYNaviViewController () <AMapNaviDriveViewDelegate,AMapNaviDriveManagerDelegate,DYMoreViewDelegate>

@property (nonatomic, strong) AMapNaviDriveManager *driveManager;
@property (nonatomic, strong) AMapNaviDriveView *driveView;
@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;
@property (nonatomic, weak) UIView *blurView;


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
    self.driveView.trackingMode = AMapNaviViewTrackingModeCarNorth;
    self.driveView.delegate = self;
    [self.view addSubview:self.driveView];
    
    //关联driveManager和driveView
    [self.driveManager addDataRepresentative:self.driveView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self.driveManager calculateDriveRouteWithStartPoints:@[self.startPoint]
                                                endPoints:@[self.endPoint]
                                                wayPoints:nil
                                          drivingStrategy:AMapNaviDrivingStrategySingleDefault];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {

    self.navigationController.navigationBar.hidden = YES;
    
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


/**
 语音回调

 @param driveManager driveManager
 @param soundString soundString
 @param soundStringType soundStringType
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType {
    
    if (SPEECH) {
        [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
    }
    
}

#pragma mark - driveViewDelegate

/**
 *  导航界面关闭按钮点击时的回调函数
 */
- (void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView {

    [self.driveManager stopNavi];
    
    if (SPEECH) {
        [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)driveViewMoreButtonClicked:(AMapNaviDriveView *)driveView {

    NSLog(@"%s", __FUNCTION__);
    
    DYMoreMenuView *moreView = [[NSBundle mainBundle] loadNibNamed:@"DYMoreView" owner:nil options:nil].lastObject;
    moreView.delegate = self;
    CGFloat moreViewHeight = 200;
    moreView.frame = CGRectMake(0, SCREEN_HEIGHT - moreViewHeight, SCREEN_WIDTH, moreViewHeight);
    moreView.nightMode.selectedSegmentIndex = self.driveView.showStandardNightType;
    moreView.trackingMode.selectedSegmentIndex = self.driveView.trackingMode;
    
    [self blurViewToView:self.driveView];
    
    [self.driveView addSubview:moreView];
    
}

- (void)blurViewToView:(UIView *)view {

    UIView *blurView = [[UIView alloc] initWithFrame:self.view.bounds];
    blurView.alpha = 0.5;
    blurView.backgroundColor = [UIColor blackColor];
    blurView.userInteractionEnabled = YES;
    [view addSubview:blurView];
    self.blurView = blurView;
    
}

#pragma mark - DYMoreViewDelegate

- (void)moreView:(DYMoreMenuView *)moreView completeClick:(UIButton *)moreButton {

    [self.blurView removeFromSuperview];
    
}

- (void)moreView:(DYMoreMenuView *)moreView nightModeSelected:(UISegmentedControl *)nightMode {
    
    self.driveView.showStandardNightType = nightMode.selectedSegmentIndex;

}

- (void)moreView:(DYMoreMenuView *)moreView trackingModeSelected:(UISegmentedControl *)trackingMode {

    self.driveView.trackingMode = trackingMode.selectedSegmentIndex;
    
}

@end
