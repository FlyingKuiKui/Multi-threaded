//
//  NSOperationQueueViewController.m
//  Multi-threaded
//
//  Created by 王盛魁 on 2017/8/22.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "NSOperationQueueViewController.h"

@interface NSOperationQueueViewController ()

@end
/**
    NSOperationQueue
  创建任务队列需要以下几步：
  1、创建子线程任务(存在两种方式)
  2、设置多个子线程任务之间的依赖关系(可以不设置，如果设置了，避免循环依赖)
  3、创建任务队列
  4、设置任务队列同步执行任务最大数(最大并发数， 1代表不设置最大并发数)
  5、将子线程任务添加到任务队列中
  注意：第二步必须在第一步后面，第四步必须在第三步后面，第五步必须在最后。
  任务创建之后，直接开启任务（[invocationOperationOne start];），任务在主线程中进行，如果将任务添加到任务队列中，则是在子线程中执行
 */
@implementation NSOperationQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NSOperationQueue";
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"开始调用多线程：NSOperationQueue");
    [self creatThreadWithNSOperationQuere];
    
    // Do any additional setup after loading the view.
}
#pragma mark - NSOperationQueue
- (void)creatThreadWithNSOperationQuere{
//    1、创建子线程任务(存在两种方式)
    // 方式1：NSBlockOperation
    NSBlockOperation *blockOperationOne = [NSBlockOperation blockOperationWithBlock:^{
        // 子线程将要执行的方法
        NSLog(@">>blockOperationOne");
    }];
    NSBlockOperation *blockOperationTwo = [NSBlockOperation blockOperationWithBlock:^{
        // 子线程将要执行的方法
        NSLog(@">>blockOperationTwo");
    }];

    // 方式2：NSInvocationOperation
    NSInvocationOperation *invocationOperationOne = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(invocationOperationOneFunc) object:nil];
    NSInvocationOperation *invocationOperationTwo = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(invocationOperationTwoFunc) object:nil];
    // 注意：任务创建之后，直接开启任务（[invocationOperationOne start];），任务在主线程中进行，如果将任务添加到任务队列中，则是在子线程中执行
    
//    2、设置多个子线程任务之间的依赖关系(可以不设置，如果设置了，避免循环依赖)
    [invocationOperationOne addDependency:invocationOperationTwo];
    // One 依赖于 Two，Two执行完成之后，执行One
    
//    3、创建任务队列
    NSOperationQueue *quere = [[NSOperationQueue alloc]init];
    
//    4、设置任务队列同步执行任务最大数(最大并发数， 1代表不设置最大并发数)
    [quere setMaxConcurrentOperationCount:2];
    // 设置为2，代表两个任务同时执行（同时执行的任务之间不存在依赖关系），设置为1，则会按照添加顺序，顺序执行
    
//    5、将子线程任务添加到任务队列中
    [quere addOperation:invocationOperationOne];
    [quere addOperation:invocationOperationTwo];
    [quere addOperation:blockOperationOne];
    [quere addOperation:blockOperationTwo];
    // 如果任务之间没有依赖关系，且最大并发数设置为1，则将会按照任务添加到队列中的顺序执行
}


- (void)invocationOperationOneFunc{
    NSLog(@">>子线程：invocationOperationOne调用的方法：%s",__func__);
}

- (void)invocationOperationTwoFunc{
    [NSThread sleepForTimeInterval:10]; // 线程10秒后执行
    NSLog(@">>子线程：invocationOperationTwo调用的方法：%s",__func__);
}

/*
 运行结果：
 1、最大并发数为1，invocationOperationTwo任务10秒后执行，One 依赖于 Two
    程序运行开始，10秒后开始打印：
    >>子线程：invocationOperationTwo调用的方法：-[NSOperationQueueViewController invocationOperationTwoFunc]
    >>子线程：invocationOperationOne调用的方法：-[NSOperationQueueViewController invocationOperationOneFunc]
    >>blockOperationOne
    >>blockOperationTwo
 2、最大并发数为2，invocationOperationTwo任务10秒后执行，One 依赖于 Two
   程序运行开始，立即打印：
    >>blockOperationOne
    >>blockOperationTwo
   运行10秒后，打印：
    >>子线程：invocationOperationTwo调用的方法：-[NSOperationQueueViewController invocationOperationTwoFunc]
    >>子线程：invocationOperationOne调用的方法：-[NSOperationQueueViewController invocationOperationOneFunc]

 */










- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
