//
//  DYMoreMenuView.m
//  ZucheDemo
//
//  Created by Yangdongwu on 2017/7/10.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYMoreMenuView.h"

@interface DYMoreMenuView ()



@end

@implementation DYMoreMenuView

- (IBAction)completeButtonClick:(id)sender {
    
    [self removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(moreView:completeClick:)]) {
        [self.delegate moreView:self completeClick:self.completeButton];
    }
    
}

- (IBAction)nightModeSelect:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(moreView:nightModeSelected:)]) {
        [self.delegate moreView:self nightModeSelected:self.nightMode];
    }
    
}

- (IBAction)trackingModeSelect:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(moreView:trackingModeSelected:)]) {
        [self.delegate moreView:self trackingModeSelected:self.trackingMode];
    }
    
}

@end
