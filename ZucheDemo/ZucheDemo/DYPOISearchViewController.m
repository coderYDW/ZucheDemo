//
//  DYPOISearchViewController.m
//  ZucheDemo
//
//  Created by mac on 2017/7/4.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYPOISearchViewController.h"
#import "ErrorInfoUtility.h"
#import "MBProgressHUD.h"

@interface DYPOISearchViewController () <UISearchBarDelegate,AMapSearchDelegate,MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) AMapSearchAPI *search;

@end

@implementation DYPOISearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.mapView = [[MAMapView alloc] init];
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.allowsBackgroundLocationUpdates = NO;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsLabels = YES;
    self.mapView.delegate = self;
//    self.mapView.userLocation.title = @"你就是";
    
    [self.view insertSubview:self.mapView atIndex:0];
    
    self.search = [AMapSearchAPI new];
    self.search.delegate = self;
    
    [self initSearchBar];
    
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    self.mapView.frame = CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT - y);
    
    
    
}

- (void)initSearchBar {
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.searchBar.barStyle     = UIBarStyleBlack;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder  = @"输入关键字";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    
    self.navigationItem.titleView = self.searchBar;
    
    [self.searchBar sizeToFit];
}


#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [self.searchBar setShowsCancelButton:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [self.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    
    if(self.searchBar.text.length == 0) {
        return;
    }
    //关键字搜索周边的点
    //[self searchPOIWithKeyword:searchBar.text];
    //检索附近的点
    //[self searchPOIAroundWithKeywords:searchBar.text];
    //检索指点范围内的点
    [self searchPOIPolygonWithKeywords:searchBar.text];
}

- (void)searchPOIWithKeyword:(NSString *)keyword {

    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];

    request.keywords = keyword;
    request.requireSubPOIs = YES;
    request.cityLimit = YES;
    request.city = @"深圳";
    
    [self.search AMapPOIKeywordsSearch:request];
    
}

- (void)searchPOIAroundWithKeywords:(NSString *)keywords {

    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:self.mapView.userLocation.coordinate.latitude longitude:self.mapView.userLocation.coordinate.longitude] ;
    request.keywords = keywords;
    request.sortrule = 0;
    request.types = @"酒店";//@"车站|酒店|电影院"
    request.requireExtension = YES;
    [self.search AMapPOIAroundSearch:request];

}

- (void)searchPOIPolygonWithKeywords:(NSString *)keywords {

    CLLocationCoordinate2D coordinate = self.mapView.userLocation.coordinate;
    NSArray *points = @[
                        [AMapGeoPoint locationWithLatitude:coordinate.latitude - 0.05 longitude:coordinate.longitude - 0.05],
                        [AMapGeoPoint locationWithLatitude:coordinate.latitude + 0.05 longitude:coordinate.longitude + 0.05]
                        ];
    
    AMapGeoPolygon *polygon = [AMapGeoPolygon polygonWithPoints:points];
    
    AMapPOIPolygonSearchRequest *request = [[AMapPOIPolygonSearchRequest alloc] init];
    
    request.polygon = polygon;
    request.keywords = keywords;
    request.requireExtension = YES;
    
    [self.search AMapPOIPolygonSearch:request];
    
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    
    NSLog(@"Error: %@ - %@", error, [ErrorInfoUtility errorDescriptionWithCode:error.code]);
    
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    
    NSLog(@"%@",response.pois);
    
    if (response.pois.count == 0) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"没有检索到结果";
        
        [hud showAnimated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        
        return;
    }
    
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:10];
    
    for (int i = 0; i < response.pois.count; ++i) {
        
        MAPointAnnotation *anno = [[MAPointAnnotation alloc] init];
        AMapPOI *poi = response.pois[i];
        anno.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        anno.title = poi.name;
        anno.subtitle = poi.address;
        
        [self.mapView addAnnotation:anno];
        [annotations addObject:anno];
        
    }
    
    [self.mapView showAnnotations:annotations animated:YES];
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {

    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        static NSString *idddd = @"keywordPoiSearch";
        MAPinAnnotationView *pinView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:idddd];
        if (pinView == nil) {
            
            pinView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:idddd];
        }
        
        pinView.canShowCallout = YES;
        pinView.canShowCallout               = YES; //点击显示视图
        pinView.animatesDrop                 = YES;  //动画插入
        pinView.draggable                    = NO; //是否允许长按拖动
        //pinView.rightCalloutAccessoryView    = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //pinView.pinColor = MAPinAnnotationColorPurple;
        
        return pinView;
    }
    
    return nil;

}




@end
