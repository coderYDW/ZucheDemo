//
//  DYReGeoDetailViewController.h
//  ZucheDemo
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYReGeoDetailViewController : UIViewController

- (instancetype)initWithRegeocode:(AMapReGeocode *)regeocode selectedBlock:(void(^)(AMapPOI *poi))selectedBlock;

@end
