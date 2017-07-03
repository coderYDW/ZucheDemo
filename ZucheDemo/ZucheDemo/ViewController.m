//
//  ViewController.m
//  ZucheDemo
//
//  Created by mac on 2017/7/3.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "DYLocationManager.h"

@interface ViewController () <MAMapViewDelegate>

@property (strong,nonatomic) AMapLocationManager *locationManager;
@property (strong,nonatomic) MAMapView *mapView;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MAMapView alloc] init];
    self.mapView.delegate = self;
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsScale = YES;
    self.mapView.showsLabels = YES;
    self.mapView.showsBuildings = YES;
    //    self.mapView.showTraffic = YES;
    
    [self.view insertSubview:self.mapView atIndex:0];

    
    __weak typeof(self) weakSelf = self;
    
    [DYLocationManager sharedManager].updateHandler = ^(CLLocation *location) {
        
        if (location) {
            
            [weakSelf.mapView setCenterCoordinate:location.coordinate animated:YES];
        }
        
    };
    
    [[DYLocationManager sharedManager] startSerialLocation];
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.mapView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    
}

- (IBAction)addAnnotation {

    MAPointAnnotation *annocation = [[MAPointAnnotation alloc] init];
    annocation.coordinate = [DYLocationManager sharedManager].userLocation.coordinate;
    annocation.title = @"yang";
    annocation.subtitle = @"sljdfklkdfjklfakdf";
    [self.mapView addAnnotation:annocation];
    
}

/**
 * @brief 当选中一个annotation views时，调用此接口
 * @param mapView 地图View
 * @param view 选中的annotation views
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {

    NSLog(@"点击大头针");
    
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view {

    NSLog(@"取消点击大头针");

}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    
    return [self annotationViewWithAnnotation:annotation mapView:mapView];
}


- (MAAnnotationView *)annotationViewWithAnnotation:(id<MAAnnotation>)annotation mapView:(MAMapView *)mapView {

    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout               = YES; //点击显示视图
        annotationView.animatesDrop                 = YES;  //动画插入
        annotationView.draggable                    = NO; //是否允许长按拖动
        annotationView.rightCalloutAccessoryView    = [UIButton buttonWithType:UIButtonTypeContactAdd];
        annotationView.pinColor = MAPinAnnotationColorPurple;
        
        return annotationView;
    }
    
    return nil;
}

@end
