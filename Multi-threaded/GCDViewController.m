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
  
 - 总结：
   并行：就是队列里面的任务（代码块，block）不是一个个执行，而是并发执行，也就是可以同时执行的意思
   串行：队列里面的任务一个接着一个执行，要等前一个任务结束，下一个任务才可以执行
   异步：具有新开线程的能力
   同步：不具有新开线程的能力，只能在当前线程执行任务
 
   并行+异步：就是真正的并发，新开有有多个线程处理任务，任务并发执行（不按顺序执行）
   串行+异步：新开一个线程，任务一个接一个执行，上一个任务处理完毕，下一个任务才可以被执行
   并行+同步：不新开线程，任务一个接一个执行
   串行+同步：不新开线程，任务一个接一个执行
 
 - 线程死锁：两个线程相互等待，两个线程都不执行任务
 - 为了防止线程死锁，避免在系统创建的串行队列中，添加同步任务。
 
 - 添加同步任务：
    - 添加同步任务，到系统创建的串行队列中，会造成**线程死锁**。
    - 添加同步任务，到手动创建的串行队列中，执行任务在主线程。
    - 添加同步任务，到系统创建的并行队列中，执行任务在主线程。
    - 添加同步任务，到手动创建的并行队列中，执行任务在主线程。
 - 添加异步任务：
    - 添加异步任务，到系统创建的串行队列中，执行任务在主线程。
    - 添加异步任务，到手动创建的串行队列中，执行任务在子线程
    - 添加异步任务，到系统创建的并行队列中，执行任务在子线程。
    - 添加异步任务，到手动创建的并行队列中，执行任务在子线程。
 - 总的来说：
    - **添加同步任务，不管在串行还是在并行队列中，所执行的任务都是在主线程中操作。**
    - **添加同步任务到系统创建的串行队列中，将会造成线程死锁。**
    - **添加异步任务**，如果添加到**系统创建的串行队列**中，那么，所执行的任务都是在**主线程中**操作；而将异步任务添加到**手动创建的队列**中，那么，所执行的任务都是**在子线程中操作**。因此，一般使用手动创建的串行队列。
 */
@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GCD";
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"GCD主线程打印");

    // 串行队列
    [self creatSerialQuere];
    NSLog(@"-------------------");
    
    // 并行队列
    [self creatConcurrentQuere];
    
    // 线程死锁
//    [self testThreadLock];
    
    // 线程安全
    [self threadSafe];
    
    
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
    // 2.1 添加异步任务
    dispatch_async(queueSerialSecond, ^{
        NSLog(@"2.1串行队列中，添加异步任务，任务内容");
        BOOL isResult = [[NSThread currentThread]isMainThread];
        NSLog(@"2.1当前线程为：%@",isResult?@"主线程":@"子线程");
    });
    // 2.2 添加同步任务
    dispatch_sync(queueSerialSecond, ^{
        NSLog(@"2.2串行队列中，添加同步任务，任务内容");
        BOOL isResult = [[NSThread currentThread]isMainThread];
        NSLog(@"2.2当前线程为：%@",isResult?@"主线程":@"子线程");
    });
    
    // 3. 释放队列，MRC模式下需要
//    dispatch_release(queueSerialSecond);
    
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
    // 2.1添加异步任务
    dispatch_async(concurrentQuereSecond, ^{
        NSLog(@"2.1并行队列，添加异步任务，任务内容");
        BOOL isResult = [[NSThread currentThread]isMainThread];
        NSLog(@"2.1当前线程为：%@",isResult?@"主线程":@"子线程");
        //如果执行完子线程任务之后，回到主线程去执行任务 异步任务
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"2.1返回主线程，执行UI界面刷新等操作");
            BOOL isResult = [[NSThread currentThread]isMainThread];
            NSLog(@"2.1-当前线程为：%@",isResult?@"主线程":@"子线程");
        });
    });
    // 2.2添加同步任务
    dispatch_sync(concurrentQuereSecond, ^{
        NSLog(@"2.2并行队列，添加同步任务，任务内容");
        BOOL isResult = [[NSThread currentThread]isMainThread];
        NSLog(@"2.2当前线程为：%@",isResult?@"主线程":@"子线程");

    });
    // 3. 释放队列，MRC模式下需要
//    dispatch_release(concurrentQuereSecond);
    
}

#pragma mark - 线程死锁
- (void)testThreadLock{
    dispatch_queue_t quere = dispatch_get_main_queue();
    dispatch_sync(quere, ^{
        NSLog(@"输出>>>>");
    });
}

#pragma mark - 线程安全
- (void)threadSafe{
    
    /*
     在GCD中提供了一种信号机制，也可以解决资源抢占问题（和同步锁的机制并不一样)
     GCD中信号量是dispatch_semaphore_t类型，支持信号通知和信号等待。
     每当发送一个信号通知，则信号量+1；每当发送一个等待信号时信号量-1,；如果信号量为0则信号会处于等待状态，直到信号量大于0开始执行。
     根据这个原理我们可以初始化一个信号量变量，默认信号量设置为1，每当有线程进入“加锁代码”之后就调用信号等待命令（此时信号量为0）开始等待，此时其他线程无法进入，执行完后发送信号通知（此时信号量为1），其他线程开始进入执行，如此一来就达到了线程同步目的。
     */
    // 如果利用信号量进行线程的加解锁，信号量初始值应当设置为1，这里为了测试，设置的值为3，orig为3
    dispatch_semaphore_t semapore_t = dispatch_semaphore_create(3); // value = 3,orig = 3
    
    // 发出等待信号，信号量-1，value值发生改变，value为0，加锁
    dispatch_semaphore_wait(semapore_t, DISPATCH_TIME_FOREVER); // value = 2,orig = 3
    
    // 发出信号，信号量+1，value值发生改变，解锁
    dispatch_semaphore_signal(semapore_t); // value = 3,orig = 3
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
