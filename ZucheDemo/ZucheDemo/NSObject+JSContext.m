//
//  NSObject+JSTest.m
//  ZucheDemo
//
//  Created by Yangdongwu on 2017/7/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSObject+JSContext.h"

@implementation NSObject (JSContext)

- (void)webView:(id)unuse didCreateJavaScriptContext:(JSContext *)ctx forFrame:(id)frame {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreateContextNotification" object:ctx];
}

@end
