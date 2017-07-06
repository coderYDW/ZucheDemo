//
//  DYInvertGeoViewController.m
//  ZucheDemo
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYInvertGeoViewController.h"
#import "DYReGeoDetailViewController.h"

@interface DYInvertGeoViewController () <MAMapViewDelegate,AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) AMapReGeocode *regeocode;


@end

@implementation DYInvertGeoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initMap];
    
    self.search = [AMapSearchAPI new];
    self.search.delegate = self;
    
}

- (void)initMap {

    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    [self.view insertSubview:self.mapView atIndex:0];
    
}

- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate {

    //发起逆地理编码
    AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    [self reGeoCodeRequestWithPoint:point];

}

- (void)reGeoCodeRequestWithPoint:(AMapGeoPoint *)point {

    AMapReGeocodeSearchRequest *reGeoRequest = [AMapReGeocodeSearchRequest new];
    reGeoRequest.location = point;
    reGeoRequest.requireExtension = YES;
    
    [self.search AMapReGoecodeSearch:reGeoRequest];

}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {

    if (response.regeocode != nil) {
        self.regeocode = response.regeocode;
        MAPointAnnotation *anno = [MAPointAnnotation new];
        anno.coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
        anno.title = response.regeocode.formattedAddress;
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotation:anno];
        [self.mapView selectAnnotation:anno animated:YES];
        
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {

    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        static NSString *pinviewid = @"pinviewid";
        
        MAPinAnnotationView *pinView = (MAPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pinviewid];
        
        if (pinView == nil) {
            pinView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinviewid];
        }
        
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
        pinView.pinColor = MAPinAnnotationColorPurple;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = button;
        [button addTarget:self action:@selector(goToDetailViewController) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hema"]];
        imageView.frame = CGRectMake(0, 0, 50, 50);
        
        pinView.leftCalloutAccessoryView = imageView;
        
        return pinView;
        
    }
    
    return nil;

}

- (void)goToDetailViewController {

    __weak typeof(self) weakSelf = self;
    DYReGeoDetailViewController *regeoVC = [[DYReGeoDetailViewController alloc] initWithRegeocode:self.regeocode selectedBlock:^(AMapPOI *poi) {
        
        [weakSelf addAnnotationWithPoi:poi];
        
    }];
    
    [self.navigationController pushViewController:regeoVC animated:YES];

}

- (void)addAnnotationWithPoi:(AMapPOI *)poi {

    //发起逆地理编码
    AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:poi.location.latitude longitude:poi.location.longitude];
    
    [self reGeoCodeRequestWithPoint:point];
    
}


@end
