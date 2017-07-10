//
//  DYMoreMenuView.h
//  ZucheDemo
//
//  Created by Yangdongwu on 2017/7/10.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DYMoreMenuView;

@protocol DYMoreViewDelegate <NSObject>
@optional

- (void)moreView:(DYMoreMenuView *)moreView completeClick:(UIButton *)moreButton;

- (void)moreView:(DYMoreMenuView *)moreView trackingModeSelected:(UISegmentedControl *)trackingMode;

- (void)moreView:(DYMoreMenuView *)moreView nightModeSelected:(UISegmentedControl *)nightMode;


@end

@interface DYMoreMenuView : UIView

@property (nonatomic, weak) id<DYMoreViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UISegmentedControl *trackingMode;

@property (weak, nonatomic) IBOutlet UISegmentedControl *nightMode;

@property (weak, nonatomic) IBOutlet UIButton *completeButton;

@end
