//
//  ViewController.m
//  Multi-threaded
//
//  Created by 王盛魁 on 2017/8/22.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "ViewController.h"

#import "PThreadViewController.h" // PThread
#import "NSThreadAndNSObjectViewController.h" // NShread/NSObject
#import "NSOperationQueueViewController.h" // NSOperationQueue
#import "GCDViewController.h"  // GCD
#import "ThreadSafeViewController.h" // 线程安全

@interface ViewController ()

@end
/*
 - 程序：每一个应用程序App都称为一个程序。
 - 进程：正在运行的一个应用程序就是一个进程，相当于一个任务，进程拥有全部的资源，负责资源的调度和分配。
 - 线程：线程就是程序中一个单独的代码块（单独的功能）。
 - 主线程：每个正在运行的程（即进程）序，至少包含一个线程，这个线程就叫做主线程。
 - 子线程：iOS允许用户自己开辟新的线程，相对于主线程而言，这些新的线程都可以称为子线程。
 - **注意：子线程与主线程是独立的运行单元，各自执行互不影响，可以并发执行。**
 */
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"多线程";
    
    UIButton *btn1 = [self creatBtnWithY:100 Title:@"PThread"];
    UIButton *btn2 = [self creatBtnWithY:150 Title:@"NShread/NSObject"];
    UIButton *btn3 = [self creatBtnWithY:200 Title:@"NSOperationQueue"];
    UIButton *btn4 = [self creatBtnWithY:250 Title:@"GCD"];
    UIButton *btn5 = [self creatBtnWithY:300 Title:@"线程安全"];

    [self.view addSubview:btn1];
    [self.view addSubview:btn2];
    [self.view addSubview:btn3];
    [self.view addSubview:btn4];
    [self.view addSubview:btn5];

//    [self verifyTheCurrentThread];
    
}
// 验证当前线程
- (void)verifyTheCurrentThread{
    BOOL isResult = [[NSThread currentThread]isMainThread];
    NSLog(@"当前线程为：%@",isResult?@"主线程":@"子线程");
}

- (UIButton *)creatBtnWithY:(CGFloat)Y Title:(NSString *)title{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, Y, [UIScreen mainScreen].bounds.size.width - 20, 40)];
    btn.tag = Y;
    btn.titleLabel.text = title;
    btn.layer.cornerRadius = 4;
    btn.layer.masksToBounds = YES;
    btn.backgroundColor = [UIColor colorWithRed:0.157 green:0.710 blue:0.914 alpha:1.00];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goToNextVC:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)goToNextVC:(UIButton *)btn{
    if (btn.tag == 100) {
        // PThread
        PThreadViewController *thread1 = [[PThreadViewController alloc]init];
        [self.navigationController pushViewController:thread1 animated:NO];
    }else if (btn.tag == 150){
        // NShread/NSObject
        NSThreadAndNSObjectViewController *thread2 = [[NSThreadAndNSObjectViewController alloc]init];
        [self.navigationController pushViewController:thread2 animated:NO];
    }else if (btn.tag == 200){
        // NSOperationQueue
        NSOperationQueueViewController *thread3 = [[NSOperationQueueViewController alloc]init];
        [self.navigationController pushViewController:thread3 animated:NO];
    }else if (btn.tag == 250){
        // GCD
        GCDViewController *thread4 = [[GCDViewController alloc]init];
        [self.navigationController pushViewController:thread4 animated:NO];
    }else if (btn.tag == 300){
        // GCD
        ThreadSafeViewController *threadSafe = [[ThreadSafeViewController alloc]init];
        [self.navigationController pushViewController:threadSafe animated:NO];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
