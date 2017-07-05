//
//  DYInvertGeoViewController.m
//  ZucheDemo
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYInvertGeoViewController.h"

@interface DYInvertGeoViewController () <MAMapViewDelegate,AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapSearchAPI *search;


@end

@implementation DYInvertGeoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    AMapGeoPoint *ponit = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    AMapReGeocodeSearchRequest *reGeoRequest = [AMapReGeocodeSearchRequest new];
    reGeoRequest.location = ponit;
    reGeoRequest.requireExtension = YES;
    
    [self.search AMapReGoecodeSearch:reGeoRequest];

}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {

    if (response.regeocode != nil) {
        
        MAPointAnnotation *anno = [MAPointAnnotation new];
        anno.coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
        anno.title = response.regeocode.formattedAddress;
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
        
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hema"]];
        imageView.frame = CGRectMake(0, 0, 50, 50);
        
        pinView.leftCalloutAccessoryView = imageView;
        
        return pinView;
        
    }
    
    return nil;

}


@end
