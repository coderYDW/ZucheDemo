//
//  ViewController.m
//  ZucheDemo
//
//  Created by mac on 2017/7/3.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "DYLocationManager.h"
#import "DYPOISearchViewController.h"
#import "DYTipViewController.h"
#import "DYGeoViewController.h"
#import "DYInvertGeoViewController.h"

@interface ViewController () <MAMapViewDelegate>

@property (strong,nonatomic) AMapLocationManager *locationManager;
@property (strong,nonatomic) MAMapView *mapView;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMap];
    
    [[DYLocationManager sharedManager] startSerialLocation];
    
    __weak typeof(self) weakSelf = self;
    
    [DYLocationManager sharedManager].updateHandler = ^(CLLocation *location) {
        
        if (location) {
            
            [weakSelf.mapView setCenterCoordinate:location.coordinate animated:YES];
        }
        
    };
    
}

- (void)initMap {

    self.mapView = [[MAMapView alloc] init];
    self.mapView.delegate = self;
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsScale = YES;
    self.mapView.showsLabels = YES;
    self.mapView.showsBuildings = YES;
    //    self.mapView.showTraffic = YES;
    
    [self.view insertSubview:self.mapView atIndex:0];
    
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    self.mapView.userLocation.title = @"您的位置在这里";
    
    //    MAUserLocationRepresentation *represent = [[MAUserLocationRepresentation alloc] init];
    //    represent.showsAccuracyRing = YES;
    //    represent.showsHeadingIndicator = YES;
    //    represent.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
    //    represent.strokeColor = [UIColor lightGrayColor];;
    //    represent.lineWidth = 2.f;
    //    represent.image = [UIImage imageNamed:@"userPosition"];
    //    [self.mapView updateUserLocationRepresentation:represent];
    
    //[self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    self.mapView.frame = CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT - y);
    
}

- (IBAction)addAnnotation {

    MAPointAnnotation *annocation = [[MAPointAnnotation alloc] init];
    annocation.coordinate = [DYLocationManager sharedManager].userLocation.coordinate;
    annocation.title = @"yang";
    annocation.subtitle = @"sljdfklkdfjklfakdf";
    [self.mapView addAnnotation:annocation];
    
}

- (IBAction)lockAnnotation {

    MAPointAnnotation *annocation = [[MAPointAnnotation alloc] init];
    [annocation setLockedScreenPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
    [annocation setLockedToScreen:YES];
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

- (IBAction)poiViewController {

    DYPOISearchViewController *poiVC = [DYPOISearchViewController new];
    
    [self.navigationController pushViewController:poiVC animated:YES];

}

- (IBAction)tipViewController:(id)sender {

    DYTipViewController *tipVC = [[DYTipViewController alloc] init];
    
    [self.navigationController pushViewController:tipVC animated:YES];
    
}

- (IBAction)geoViewController:(id)sender {

    DYGeoViewController *geoVC = [[DYGeoViewController alloc] init];
    
    [self.navigationController pushViewController:geoVC animated:YES];

}

- (IBAction)invertGeoViewController:(id)sender {

    DYInvertGeoViewController *invertGeoVC = [[DYInvertGeoViewController alloc] init];
    
    [self.navigationController pushViewController:invertGeoVC animated:YES];
    
}

- (void)dealloc {

    NSLog(@"%s", __FUNCTION__);
}

@end
