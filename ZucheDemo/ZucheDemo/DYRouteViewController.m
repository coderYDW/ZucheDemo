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
#define WZKGDA CLLocationCoordinate2DMake(22.563855, 114.11351)
#define SZBZ   CLLocationCoordinate2DMake(22.616579, 114.036937)

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

@end

@implementation DYRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initMapView];
    
    self.startCoordinate = WZKGDA;
    self.destinationCoordinate = SZBZ;
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    [self addDefaultAnnotations];
    
    [self searchRoute];
    
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

- (void)searchRoute {
    
    self.startAnnotation.coordinate = self.startCoordinate;
    self.destinationAnnotation.coordinate = self.destinationCoordinate;
    
    AMapDrivingRouteSearchRequest *request = [[AMapDrivingRouteSearchRequest alloc] init];
    
    request.requireExtension = YES;
    request.strategy = 0;
    request.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    request.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude longitude:self.destinationCoordinate.longitude];
    
    [self.search AMapDrivingRouteSearch:request];

}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {

}

- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response {

    if (response.route == nil) {
        return;
    }
    
    NSLog(@"路线个数 = %zd",response.count);
    
    self.route = response.route;
    
    if (response.count > 0) {
        //显示路线
        [self showRoute:request path:response.route.paths.firstObject];
        //[self showAllRoute:request];
        
    }
    
    

}

- (void)showAllRoute:(AMapRouteSearchBaseRequest *)request {

    for (int i = 0; i < self.route.paths.count; ++i) {
        [self showRoute:request path:self.route.paths[i]];
    }
    
}

- (void)showRoute:(AMapRouteSearchBaseRequest *)request path:(AMapPath *)path {
    
    self.naviRoute = [MANaviRoute naviRouteForPath:path withNaviType:MANaviAnnotationTypeDrive showTraffic:NO startPoint:request.origin endPoint:request.destination];
    
    [self.naviRoute addToMapView:self.mapView];
    
    [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines] edgePadding:UIEdgeInsetsMake(-10, 10, -10, 10) animated:YES];

}


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

@end
