//
//  ViewController.m
//  Multi-threaded
//
//  Created by 王盛魁 on 2017/8/22.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self verifyTheCurrentThread];
    
    [self addThreadWithPTHread];
}
// 验证当前线程
- (void)verifyTheCurrentThread{
    BOOL isResult = [[NSThread currentThread]isMainThread];
    NSLog(@"%d",isResult);
    // 1代表主线程
}
#pragma mark - PThread
// 利用PTHread添加线程
- (void)addThreadWithPTHread{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
