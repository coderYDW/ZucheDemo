//
//  DYTipViewController.m
//  ZucheDemo
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYTipViewController.h"
#import "DYTipAnnotation.h"

@interface DYTipViewController () <UISearchResultsUpdating,UISearchBarDelegate,MAMapViewDelegate,UITableViewDelegate,UITableViewDataSource,AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tips;

@end

@implementation DYTipViewController

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.searchController.active = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initMap];
    [self initSearchController];
    [self initTableView];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.mapView.frame = self.view.bounds;
    
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
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    self.mapView.userLocation.title = @"您的位置在这里";
    
}



- (void)initSearchController {

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];

    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    self.searchController.searchBar.placeholder = @"请输入查询内容";
    self.searchController.searchBar.barStyle = UIBarStyleBlack;
    [self.searchController.searchBar sizeToFit];
    
    self.navigationItem.titleView = self.searchController.searchBar;
}
#pragma mark - tableVIew
- (void)initTableView
{
    //    CGFloat tableY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *tipIdentifier  = @"tip";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:tipIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tipIdentifier];
    }
    AMapTip *tip = self.tips[indexPath.row];
    cell.textLabel.text = tip.name;
    cell.detailTextLabel.text = tip.address;
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.searchController.active = NO;
    
    AMapTip *tip = self.tips[indexPath.row];
    
    [self mapViewAddAnnotationWithTip:tip];

}
#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {

//    searchController.active = YES;
    self.tableView.hidden = !searchController.isActive;
    //开始搜索
    [self searchTipsWithKey:searchController.searchBar.text];
    
    if (searchController.isActive && searchController.searchBar.text.length > 0)
    {
        searchController.searchBar.placeholder = searchController.searchBar.text;
    }
}

- (void)searchTipsWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = key;
    tips.city     = @"深圳";
    tips.cityLimit = YES; //是否限制城市
    
    [self.search AMapInputTipsSearch:tips];
}

#pragma mark - AMapSearchDelegate

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response {

    if (response.tips.count == 0) {
        return;
    }

    [self.tips setArray:response.tips];
    [self.tableView reloadData];
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {

}

#pragma mark - 地图
- (void)mapViewAddAnnotationWithTip:(AMapTip *)tip {

    [self.mapView removeAnnotations:self.mapView.annotations];
    
    DYTipAnnotation *tipAnnotation = [[DYTipAnnotation alloc] initWithTip:tip];
    
    [self.mapView addAnnotation:tipAnnotation];
    
    [self.mapView showAnnotations:@[tipAnnotation] animated:YES];

}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {

    if ([annotation isKindOfClass:[DYTipAnnotation class]]) {
        
        
        static NSString *tipViewId = @"tipViewId";
        MAPinAnnotationView *tipView = (MAPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:tipViewId];
        if (tipView == nil) {
            tipView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:tipViewId];
        }
        
        tipView.canShowCallout = YES;
        
        return tipView;
        
    }
    
    return nil;

}

#pragma mark - 懒加载
- (NSMutableArray *)tips {
    if (_tips == nil) {
        _tips = [[NSMutableArray alloc] init];
    }
    return _tips;
}



@end
