//
//  DYRouteViewController.m
//  ZucheDemo
//
//  Created by Yangdongwu on 2017/7/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYRouteViewController.h"
#import "MANaviRoute.h"
#import "CommonUtility.h"
//114.124223,22.535561  深圳站
//114.036937,22.616579  深圳北站
//114.110985,22.567428  红岭北
#define WZKGDA CLLocationCoordinate2DMake(22.563855, 114.11351)
#define SZBZ   CLLocationCoordinate2DMake(22.616579, 114.036937)
#define SZZ   CLLocationCoordinate2DMake(22.535561, 114.124223)
#define HLBZ   CLLocationCoordinate2DMake(22.567428, 114.110985)

@interface DYRouteViewController () <MAMapViewDelegate,AMapSearchDelegate>

///开始坐标
@property (nonatomic, assign) CLLocationCoordinate2D  startCoordinate;
///终点坐标
@property (nonatomic, assign) CLLocationCoordinate2D  destinationCoordinate;

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;

@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) AMapRoute *route;

@property (nonatomic, strong) MANaviRoute *naviRoute;

@property (nonatomic, assign) BOOL lineOn;

@end

@implementation DYRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initMapView];
    
}

- (void)initMapView {

    CGRect rect = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    self.mapView = [[MAMapView alloc] initWithFrame:rect];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    [self.view insertSubview:self.mapView atIndex:0];

}

- (void)addDefaultAnnotations
{
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title      = @"起点";
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    self.startAnnotation = startAnnotation;
    
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = self.destinationCoordinate;
    destinationAnnotation.title      = @"终点";
    destinationAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    self.destinationAnnotation = destinationAnnotation;
    
    [self.mapView addAnnotation:startAnnotation];
    [self.mapView addAnnotation:destinationAnnotation];
}

#pragma mark - 搜索各种路线

- (void)searchBusRoute {

    self.startAnnotation.coordinate = self.startCoordinate;
    self.destinationAnnotation.coordinate = self.destinationCoordinate;
    
    AMapTransitRouteSearchRequest *request = [AMapTransitRouteSearchRequest new];
    
    request.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    request.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude longitude:self.destinationCoordinate.longitude];
    
    request.city = @"深圳";
    request.requireExtension = YES;
    
    [self.search AMapTransitRouteSearch:request];
    
}

- (void)searchWalkingRoute {

    self.startAnnotation.coordinate = self.startCoordinate;
    self.destinationAnnotation.coordinate = self.destinationCoordinate;
    
    AMapWalkingRouteSearchRequest *request = [AMapWalkingRouteSearchRequest new];
    request.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    request.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude longitude:self.destinationCoordinate.longitude];
    request.multipath = 1;
    [self.search AMapWalkingRouteSearch:request];

}

- (void)searchDriveRoute {
    
    AMapDrivingRouteSearchRequest *request = [[AMapDrivingRouteSearchRequest alloc] init];
    
    request.requireExtension = YES;
    request.strategy = 5;
    request.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    request.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude longitude:self.destinationCoordinate.longitude];
    
    [self.search AMapDrivingRouteSearch:request];

}

- (AMapRouteSearchBaseRequest *)originAndDestinationWithRequest:(AMapRouteSearchBaseRequest *)request {
    
    self.startAnnotation.coordinate = self.startCoordinate;
    self.destinationAnnotation.coordinate = self.destinationCoordinate;
    
    request.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    request.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude longitude:self.destinationCoordinate.longitude];
    
    return request;
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {

}

- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response {

    if (response.route == nil) {
        return;
    }
    
    NSLog(@"route path count = %zd",response.route.paths.count);
    NSLog(@"route transit count = %zd",response.route.transits.count);
    self.route = response.route;
    
    if (response.count > 0) {
        //显示路线
        //[self showAllRoute:request];
        if ([request isKindOfClass:[AMapTransitRouteSearchRequest class]]) {
            
            [self showBusRoute:(AMapTransitRouteSearchRequest *)request transit:response.route.transits.firstObject];
            
        }
        else {
        
            [self showRoute:request path:response.route.paths.firstObject];
        
        }
    }
    
    

}

#pragma mark - 展示路线
- (void)showBusRoute:(AMapTransitRouteSearchRequest *)request transit:(AMapTransit *)transit {

    self.naviRoute = [MANaviRoute naviRouteForTransit:transit startPoint:request.origin endPoint:request.destination];
    
    [self.naviRoute addToMapView:self.mapView];
    
    if (self.naviRoute.routePolylines.count) {
        
        [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines] edgePadding:UIEdgeInsetsMake(-10, 10, -10, 10) animated:YES];
    }

}

- (void)showAllRoute:(AMapRouteSearchBaseRequest *)request {

    for (int i = 0; i < self.route.paths.count; ++i) {
        [self showRoute:request path:self.route.paths[i]];
    }
    
}

- (void)showRoute:(AMapRouteSearchBaseRequest *)request path:(AMapPath *)path {
    
    MANaviAnnotationType type = MANaviAnnotationTypeWalking;
    if ([request isKindOfClass:[AMapWalkingRouteSearchRequest class]]) {
        type = MANaviAnnotationTypeWalking;
    }
    if ([request isKindOfClass:[AMapDrivingRouteSearchRequest class]]) {
        type = MANaviAnnotationTypeDrive;
    }
    if ([request isKindOfClass:[AMapTransitRouteSearchRequest class]]) {
        type = MANaviAnnotationTypeBus;
    }
    if([request isKindOfClass:[AMapRidingRouteSearchRequest class]]) {
        type = MANaviAnnotationTypeRiding;
    }
    
    self.naviRoute = [MANaviRoute naviRouteForPath:path withNaviType:type showTraffic:NO startPoint:request.origin endPoint:request.destination];
    
    [self.naviRoute addToMapView:self.mapView];
    
    if (self.naviRoute.routePolylines.count) {
        
        [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines] edgePadding:UIEdgeInsetsMake(-10, 10, -10, 10) animated:YES];
    }
    

}

#pragma mark - 线的样式
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth   = 8;
        polylineRenderer.lineDash = YES;
        polylineRenderer.strokeColor = [UIColor redColor];
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MANaviPolyline class]])
    {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = 8;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking)
        {
            polylineRenderer.strokeColor = self.naviRoute.walkingColor;
        }
        else if (naviPolyline.type == MANaviAnnotationTypeRailway)
        {
            polylineRenderer.strokeColor = self.naviRoute.railwayColor;
        }
        else
        {
            polylineRenderer.strokeColor = self.naviRoute.routeColor;
        }
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 10;
        polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
        polylineRenderer.gradient = YES;
        
        return polylineRenderer;
    }
    
    return nil;
}

#pragma mark - 大头针样式
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:routePlanningCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.image = nil;
        
        if ([annotation isKindOfClass:[MANaviAnnotation class]])
        {
            switch (((MANaviAnnotation*)annotation).type)
            {
                case MANaviAnnotationTypeRailway:
                    poiAnnotationView.image = [UIImage imageNamed:@"railway_station"];
                    break;
                    
                case MANaviAnnotationTypeBus:
                    poiAnnotationView.image = [UIImage imageNamed:@"bus"];
                    break;
                    
                case MANaviAnnotationTypeDrive:
                    poiAnnotationView.image = [UIImage imageNamed:@"car"];
                    break;
                    
                case MANaviAnnotationTypeWalking:
                    poiAnnotationView.image = [UIImage imageNamed:@"man"];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            /* 起点. */
            if ([[annotation title] isEqualToString:@"起点"])
            {
                poiAnnotationView.image = [UIImage imageNamed:@"startPoint"];
            }
            /* 终点. */
            else if([[annotation title] isEqualToString:@"终点"])
            {
                poiAnnotationView.image = [UIImage imageNamed:@"endPoint"];
            }
            
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}

#pragma mark - 更新位置
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    
    NSLog(@"{%f,%f}",mapView.userLocation.coordinate.latitude,mapView.userLocation.coordinate.longitude);

}

#pragma mark - 地图加载完毕
- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView {
    
    NSLog(@"%s", __FUNCTION__);
    
    if (self.lineOn == NO) {
        self.lineOn = YES;
        self.startCoordinate = self.mapView.userLocation.coordinate;
        self.destinationCoordinate = SZBZ;
        
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
        
        [self addDefaultAnnotations];
        
        [self searchBusRoute];
        //[self searchDriveRoute];
        //[self searchWalkingRoute];
    }
    
    
    //[CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus]
}

@end
