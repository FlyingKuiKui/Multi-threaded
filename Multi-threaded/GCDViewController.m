//
//  GCDViewController.m
//  Multi-threaded
//
//  Created by 王盛魁 on 2017/8/22.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "GCDViewController.h"

@interface GCDViewController ()

@end
/**
 GCD
 - 无论是方法还是其它，均以`dispatch_`开头,与其有关的枚举均以`DISPATCH_QUEUE_`开头
 - 是苹果主推的一种多线程计数，Apple自己封装，是一套纯C的代码，都是C语言的API，抽象程度最高，执行效率最高（1.C语言 2.充分利用设备多核的特性）
 - 使用步骤：
  - 创建任务队列（串行或者并行）
  - 添加任务（同步或异步）
  - MRC下需要释放任务队列
  
 总结：
 并行：就是队列里面的任务（代码块，block）不是一个个执行，而是并发执行，也就是可以同时执行的意思
 串行：队列里面的任务一个接着一个执行，要等前一个任务结束，下一个任务才可以执行
 异步：具有新开线程的能力
 同步：不具有新开线程的能力，只能在当前线程执行任务
 
 并行+异步：就是真正的并发，新开有有多个线程处理任务，任务并发执行（不按顺序执行）
 串行+异步：新开一个线程，任务一个接一个执行，上一个任务处理完毕，下一个任务才可以被执行
 并行+同步：不新开线程，任务一个接一个执行
 串行+同步：不新开线程，任务一个接一个执行
 
 
 */
@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GCD";
    self.view.backgroundColor = [UIColor whiteColor];

    [self creatSerialQuere];
    
    [self creatConcurrentQuere];
    
    // Do any additional setup after loading the view.
}
#pragma mark - 串行队列
- (void)creatSerialQuere{
    // 1.串行队列有两种获取方式
    // 1.1串行队列获取方式一(系统创建)：
    // 使用系统创建好的串行队列，往队列中添加的任务是在主线程中执行的；
    dispatch_queue_t queueSerialFirst = dispatch_get_main_queue();
    
    // 1.2串行队列获取方式二(手动创建)：
    // 参数一：队列的唯一标识，一般以反域名的方式来标识；参数二：设置队列方式，即串行还是并行，DISPATCH_QUEUE_SERIAL 代表串行队列
    dispatch_queue_t queueSerialSecond = dispatch_queue_create("com.wangsk.second", DISPATCH_QUEUE_SERIAL);
    
    // 2. 添加任务
    // 2.1 异步添加任务
    dispatch_async(queueSerialSecond, ^{
        NSLog(@"串行队列中，异步添加任务，任务内容");
        BOOL isResult = [[NSThread currentThread]isMainThread];
        NSLog(@"当前线程为：%@",isResult?@"主线程":@"子线程");
    });
    // 2.2 同步添加任务
    dispatch_sync(queueSerialSecond, ^{
        NSLog(@"串行队列中，同步添加任务，任务内容");
        BOOL isResult = [[NSThread currentThread]isMainThread];
        NSLog(@"当前线程为：%@",isResult?@"主线程":@"子线程");
    });
    
    // 3. 释放队列，MRC模式下需要
//    dispatch_release(queueSerialSecond);
    
//    同步添加任务，不管在任何情况下，所执行的任务都是在主线程中操作；
//    异步添加任务，如果添加到系统创建的串行队列中，那么，所执行的任务都是在主线程中操作；而将异步任务添加到手动创建的队列中，那么，所执行的任务都是在子线程中操作。因此，一般使用手动创建的串行队列。
}

#pragma mark - 并行队列
- (void)creatConcurrentQuere{
    // 1. 并行队列有两种获取方式
    // 1.1 并行队列获取方式一(系统创建)：
    // 参数一：队列优先级；参数二：预留参数
    dispatch_queue_t concurrentQuereFirst = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 1.2 并行队列获取方式二(手动创建)：
    dispatch_queue_t concurrentQuereSecond = dispatch_queue_create("com.wangsk.concurrent", DISPATCH_QUEUE_CONCURRENT);
    
    // 2. 添加任务
    // 添加异步任务
    dispatch_async(concurrentQuereSecond, ^{
        NSLog(@"串行队列，异步添加任务，任务内容");
        BOOL isResult = [[NSThread currentThread]isMainThread];
        NSLog(@"当前线程为：%@",isResult?@"主线程":@"子线程");
        //如果执行完子线程任务之后，回到主线程去执行任务 异步任务
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"返回主线程，执行UI界面刷新等操作");
            BOOL isResult = [[NSThread currentThread]isMainThread];
            NSLog(@"当前线程为：%@",isResult?@"主线程":@"子线程");
        });
    });
    
    // 3. 释放队列，MRC模式下需要
//    dispatch_release(concurrentQuereSecond);
    
}







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
