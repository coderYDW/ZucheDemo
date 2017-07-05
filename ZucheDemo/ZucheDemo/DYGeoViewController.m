//
//  DYGeoViewController.m
//  ZucheDemo
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYGeoViewController.h"

@interface DYGeoViewController () <MAMapViewDelegate,UISearchBarDelegate,AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) AMapSearchAPI *search;

@end

@implementation DYGeoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initMapView];
    
    [self initSearchBar];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
}

#pragma mark - 地图

- (void)initMapView {

    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    [self.view insertSubview:self.mapView atIndex:0];
    
}

- (void)initSearchBar {

    UISearchBar *searchBar = [[UISearchBar alloc] init];
    self.searchBar = searchBar;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"请输入关键字";
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.searchBar sizeToFit];
    
    self.navigationItem.titleView = self.searchBar;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    if (searchBar.text.length == 0) {
        return;
    }
    
    AMapGeocodeSearchRequest *request = [[AMapGeocodeSearchRequest alloc] init];
    request.address = searchBar.text;
    [self.search AMapGeocodeSearch:request];
    
    [self.searchBar resignFirstResponder];
    
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"搜索失败");
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response {

    if (response.geocodes.count == 0) {
        return;
    }
    
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:1];
    for (AMapGeocode *geocode in response.geocodes) {
        
        MAPointAnnotation *anno = [[MAPointAnnotation alloc] init];
        anno.coordinate = CLLocationCoordinate2DMake(geocode.location.latitude, geocode.location.longitude);
        [annotations addObject:anno];
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:annotations];
    [self.mapView showAnnotations:annotations animated:YES];

}

@end
