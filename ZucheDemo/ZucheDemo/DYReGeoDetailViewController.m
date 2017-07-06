//
//  DYReGeoDetailViewController.m
//  ZucheDemo
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYReGeoDetailViewController.h"

@interface DYReGeoDetailViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property(nonatomic,strong) AMapReGeocode *reGeoCode;

@property (nonatomic, copy) void (^selectedBlock)(AMapPOI *poi);

@end

@implementation DYReGeoDetailViewController

- (instancetype)initWithRegeocode:(AMapReGeocode *)regeocode selectedBlock:(void(^)(AMapPOI *poi))selectedBlock
{
    self = [super init];
    if (self) {
        self.reGeoCode = regeocode;
        self.selectedBlock = selectedBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initTableView];
}

- (void)initTableView {

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"pois"];

}

#pragma mark - 数据源方法

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//    NSInteger section = 0;
//    
//    if (self.reGeoCode.pois.count) {
//        section ++;
//    }
//    if (self.reGeoCode.aois.count) {
//        section ++;
//    }
//    
//    return section;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.reGeoCode.pois.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pois"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"pois"];
    }
    
    AMapPOI *poi = self.reGeoCode.pois[indexPath.row];
    
    cell.textLabel.text = poi.name;
    cell.detailTextLabel.text = poi.address;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - tableView代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AMapPOI *poi = self.reGeoCode.pois[indexPath.row];
    
    if (self.selectedBlock) {
        self.selectedBlock(poi);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 50;
    
}

@end
