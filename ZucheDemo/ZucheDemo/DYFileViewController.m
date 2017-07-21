//
//  DYFileViewController.m
//  ZucheDemo
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYFileViewController.h"

@interface DYFileViewController ()

@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation DYFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.fileManager = [NSFileManager defaultManager];
    
    NSURL *temporaryPath = [self.fileManager temporaryDirectory];
    
    //[self.fileManager URLsForDirectory:NSApplicationDirectory inDomains:NSUserDomainMask];
    
    NSLog(@"temporaryPath = %@",temporaryPath.absoluteString);
    
    
}

@end
