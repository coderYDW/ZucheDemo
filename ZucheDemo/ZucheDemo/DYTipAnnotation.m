//
//  DYTipAnnotation.m
//  ZucheDemo
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYTipAnnotation.h"

@interface DYTipAnnotation ()

@property (nonatomic, strong) AMapTip *tip;


@end

@implementation DYTipAnnotation

- (NSString *)title {
    
    return self.tip.name;
}


- (NSString *)subtitle {
    
    return self.tip.address;
}

- (CLLocationCoordinate2D)coordinate {
    
    return CLLocationCoordinate2DMake(self.tip.location.latitude, self.tip.location.longitude);
}

- (instancetype)initWithTip:(AMapTip *)tip {
    
    self = [super init];
    if (self) {
        self.tip = tip;
    }
    return self;
}

@end
