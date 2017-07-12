//
//  DYJSObject.m
//  ZucheDemo
//
//  Created by Yangdongwu on 2017/7/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DYJSObject.h"

#import <JavaScriptCore/JavaScriptCore.h>

@protocol DYJSExport111 <JSExport>

- (void)nslog:(NSString *)str;

@end

@interface DYJSObject () <DYJSExport111>

@end

@implementation DYJSObject

- (void)nslog:(NSString *)str {

    NSLog(@"%@",str);

}

@end
