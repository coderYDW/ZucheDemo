//
//  DYRouteViewController.m
//  ZucheDemo
//
//  Created by Yangdongwu on 2017/7/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYRouteViewController.h"

#define WZKGDA CLLocationCoordinate2DMake(22.563855, 114.11351)
#define SZBZ   CLLocationCoordinate2DMake(22.616579, 114.036937)

@interface DYRouteViewController () <MAMapViewDelegate>

///开始坐标
@property (nonatomic, assign) CLLocationCoordinate2D  startCoordinate;
///终点坐标
@property (nonatomic, assign) CLLocationCoordinate2D  destinationCoordinate;

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation DYRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initMapView];
    
}

- (void)initMapView {

    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    [self.view insertSubview:self.mapView atIndex:0];

}

@end
