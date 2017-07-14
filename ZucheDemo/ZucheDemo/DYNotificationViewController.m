//
//  DYNotificationViewController.m
//  ZucheDemo
//
//  Created by Yangdongwu on 2017/7/13.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYNotificationViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface DYNotificationViewController ()

@property (nonatomic, strong) UIButton *sendNotifitation;

@end

@implementation DYNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.sendNotifitation.frame = CGRectMake(100, 200, 100, 50);
    
    [self.view addSubview:self.sendNotifitation];
    
    [self requsetNotificationAuthorization];
    
}

- (void)requsetNotificationAuthorization {

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"request authorization succeeded!");
        }
    }];
    
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        NSLog(@"%@",settings);
    }];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
    //Local Notification
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Introduction to Notifications";
    content.subtitle = @"Session 707";
    content.body = @"Woah! These new notifications look amazing! Don’t you agree?";
    content.badge = @1;
    
    //    UILocalNotification *local = [[UILocalNotification alloc] init];
    //    //弹窗设置
    //    local.alertTitle = @"This is a title";
    //    local.alertBody = @"This is a body";
    //    //声音设置
    //    local.soundName = UILocalNotificationDefaultSoundName;
    //    //重复时间间隔
    //    local.repeatInterval = NSCalendarUnitHour;
    //    //通知时间
    //    local.fireDate = [NSDate dateWithTimeIntervalSinceNow:4];
    //    //通知的用户信息
    //    local.userInfo = @{  };
    //    //添加到通知池
    //    [[UIApplication sharedApplication] scheduleLocalNotification:local];
    //
    //
    //
    //    //================== type =================//
    //
    //    UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
    //
    //    //================== settings =================//
    //
    //    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    //
    //    //================== 注册通知 =================//
    //    
    //    [application registerUserNotificationSettings:settings];
    //
}

- (void)sendNoti {

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Introduction to Notifications";
    content.subtitle = @"Session 707";
    content.body = @"Woah! These new notifications look amazing! Don’t you agree?";
    content.badge = @1;
    
//    CLRegion *region = [[CLRegion alloc] init];
//    UNLocationNotificationTrigger *trigger1 = [UNLocationNotificationTrigger triggerWithRegion:region repeats:YES];
    
    UNTimeIntervalNotificationTrigger *trigger2 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:100 repeats:YES];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.weekday = 2;
    components.hour = 8;
    UNCalendarNotificationTrigger *trigger3 = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    
    
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    NSString *requestIdentifier = @"sampleRequestTimeInterval";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier
                                                                          content:content
                                                                          trigger:trigger2];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
    
    
}


- (void)dealloc {

    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    
    [UNUserNotificationCenter cancelPreviousPerformRequestsWithTarget:self];
    
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];

}

- (UIButton *)sendNotifitation {

    if (_sendNotifitation == nil) {
        _sendNotifitation = [[UIButton alloc] init];
        [_sendNotifitation setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _sendNotifitation.backgroundColor = [UIColor redColor];
        [_sendNotifitation setTitle:@"发送通知" forState:UIControlStateNormal];
        [_sendNotifitation addTarget:self action:@selector(sendNoti) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendNotifitation;

}

@end
