//
//  ThreadSafeViewController.m
//  Multi-threaded
//
//  Created by 王盛魁 on 2017/8/25.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "ThreadSafeViewController.h"
#import <pthread.h>
#import <libkern/OSAtomic.h> // OSSpinLock
#import <os/lock.h> // os_unfair_lock
@interface ThreadSafeViewController (){
    
    pthread_rwlock_t rwLock;
    // POSIX Conditions
    pthread_mutex_t mutex;
    pthread_cond_t condition;
    Boolean     ready_to_go;
    
}
@property (nonatomic, strong) NSRecursiveLock *recursiveLock;

@property (nonatomic, strong) NSConditionLock *conditionLock;

@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, assign) BOOL downloadFinish;


@end

@implementation ThreadSafeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"线程安全";
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"线程安全主线程打印");
    // synchronized
    [self threadSafeSynchronziedWithOnject:self];
    
    // NSLock
    [self threadSafeNSLock];
    
    // NSConditionLock
    [self threadSafeNSConditionLock];
    
    // NSRecursiveLock
    [self threadSafeNSRecursiveLock];
    
    // NSCondition
    [self threadSafeNSCondition];
    
    // pthread_mutex
    [self threadSafePthread_mutex];
    
    // pthread_rwlock
    [self threadSafePthread_rwlock];
    
    // POSIX Conditions
    [self threadSafePOSIXConditions];
    
    // OSSpinLock
//    [self threadSafeOSSpinLock];
    
    // os_unfair_lock
    [self threadSafeOs_unfair_lock];
    
    // 信号量机制
    [self threadSafeSemaphore];

}
#pragma mark - synchronized
/**
  一个便捷的创建互斥锁的方式，它做了其他互斥锁所做的所有的事情
  括号(anyObject)内是锁对象，设置锁对象时必须保证多个线程访问的都是同一个对象,锁对象必须是唯一的,还必须是id类型；操作尽量要少些，因为代码越多，效率越低。
  如果你在不同的线程中传过去的是一样的标识符(锁对象)，先获得锁的会锁定代码块，另一个线程将被阻塞，如果传递的是不同的标识符，则不会造成线程阻塞。

 */
- (void)threadSafeSynchronziedWithOnject:(id)anyObject{
    // anyObject 即锁对象
    @synchronized (anyObject) {
        // 编写互斥操作代码
    }
}
#pragma mark - NSLock
/**
  NSLock实现了最基本的互斥锁，遵循了 NSLocking 协议
  通过 lock 和 unlock 来进行锁定和解锁
 */
- (void)threadSafeNSLock{
    NSLock *oneLock = [[NSLock alloc]init];
    [oneLock lock]; // 加锁
    [oneLock unlock];  // 解锁
}


#pragma mark - NSConditionLock
/**
  - 互斥锁
  - 可以在使得在某个条件下进行锁定和解锁。
  - 它和 NSCondition 很像，但实现方式是不同的。
 - 当两个线程需要特定顺序执行的时候，例如生产者消费者模型，则可以使用 NSConditionLock 。
  - 当生产者执行的时候，消费者可以通过特定的条件获得锁，当生产者完成执行的时候，它将解锁该锁，然后把锁的条件设置成唤醒消费者线程的条件。锁定和解锁的调用可以随意组合，lock 和 unlockWithCondition: 配合使用 lockWhenCondition: 和 unlock 配合使用。
 - 当生产者释放锁的时候，把条件设置成了1。这样消费者可以获得该锁，进而执行程序，如果消费者获得锁的条件和生产者释放锁时给定的条件不一致，则消费者永远无法获得锁，也不能执行程序。同样，如果消费者释放锁给定的条件和生产者获得锁给定的条件不一致的话，则生产者也无法获得锁，程序也不能执行。

 */
- (void)threadSafeNSConditionLock{
    self.conditionLock = [[NSConditionLock alloc]init];
    NSThread *threadOne = [[NSThread alloc]initWithTarget:self selector:@selector(producer) object:nil];
    threadOne.name = @"threadOne";
    NSThread *threadTwo = [[NSThread alloc]initWithTarget:self selector:@selector(consumer) object:nil];
    threadTwo.name = @"threadTwo";
//    [threadOne start];
//    [threadTwo start];
    
}
- (void)producer {
    while (YES) {
        [self.conditionLock lock];
        NSLog(@"produce something");
        [self.conditionLock unlockWithCondition:10];
    }
}

- (void)consumer {
    while (YES) {
        [self.conditionLock lockWhenCondition:10];
        NSLog(@"consumer something");
        [self.conditionLock unlockWithCondition:0];
    }
}
#pragma mark - NSRecursiveLock
/**
  递归锁：可以被一个线程多次获得，而不会引起死锁。
  它记录了成功获得锁的次数，每一次成功的获得锁，必须有一个配套的释放锁和其对应，这样才不会引起死锁。
  只有当所有的锁被释放之后，其他线程才可以获得锁。
 */
- (void)threadSafeNSRecursiveLock{
    self.recursiveLock = [[NSRecursiveLock alloc] init];
    
    [self RecuriveLockFuncWith:5];
}
- (void)RecuriveLockFuncWith:(int)value{
    [self.recursiveLock lock];
    // 每次加锁 recursion count 加1
    if (value != 0)
    {
        --value;
        [self RecuriveLockFuncWith:value];
    }
    // 每次解锁 recursion count 减1
    // 当recursion count为零时，完全解锁
    [self.recursiveLock unlock];
}

#pragma mark - NSCondition
/**
  - 分布锁
  - 通过它可以实现不同线程的调度。
  - 一个线程被某一个条件所阻塞，直到另一个线程满足该条件从而发送信号给该线程使得该线程可以正确的执行。
  - 比如说，你可以开启一个线程下载图片，一个线程处理图片。这样的话，需要处理图片的线程由于没有图片会阻塞，当下载线程下载完成之后，则满足了需要处理图片的线程的需求，这样可以给定一个信号，让处理图片的线程恢复运行。
 
 */
- (void)threadSafeNSCondition{
    self.condition = [[NSCondition alloc]init];
    NSThread *threadOne = [[NSThread alloc]initWithTarget:self selector:@selector(download) object:nil];
    threadOne.name = @"threadOne";
    NSThread *threadTwo = [[NSThread alloc]initWithTarget:self selector:@selector(doStuffWithDownloadPicture) object:nil];
    threadTwo.name = @"threadTwo";
//    [threadOne start];
//    [threadTwo start];

}
- (void)download {
    @autoreleasepool {
        [self.condition lock];
        NSLog(@"子线程%@下载文件",[NSThread currentThread].name);
        
        if (self.downloadFinish) { // 下载结束后，给另一个线程发送信号，唤起另一个处理程序
            [self.condition signal];
            [self.condition unlock];
        }
    }
    
}
- (void)doStuffWithDownloadPicture {
    @autoreleasepool {
        [self.condition lock];
        while (self.downloadFinish == NO) {
            [self.condition wait];
        }
        NSLog(@"子线程%@处理下载后的文件",[NSThread currentThread].name);
        [self.condition unlock];
    }
}

#pragma mark - pthread_mutex
/**
  - 需要导入框架<pthread.h>
  - 一种超级易用的互斥锁
  - 使用的时候，只需要初始化一个 pthread_mutex_t 
  - 用 pthread_mutex_lock 来锁定 
  - 用 pthread_mutex_unlock 来解锁，
  - 当使用完成后，记得调用 pthread_mutex_destroy 来销毁锁
 
 
 */
- (void)threadSafePthread_mutex{
    // 设置锁类型
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    // 初始化锁
    pthread_mutex_t lock;
    pthread_mutex_init(&lock,&attr);
    // 加锁
    pthread_mutex_lock(&lock);
    // 数据操作代码
    
    // 解锁
    pthread_mutex_unlock(&lock);
    // 销毁锁
    pthread_mutex_destroy(&lock);
    pthread_mutexattr_destroy(&attr);
    
}
#pragma mark - pthread_rwlock
/**
  - 读写锁，在对文件进行操作的时候，写操作是排他的，一旦有多个线程对同一个文件进行写操作，后果不可估量，但读是可以的，多个线程读取时没有问题的。
  - 当读写锁被一个线程以读模式占用的时候，写操作的其他线程会被阻塞，读操作的其他线程还可以继续进行。
  - 当读写锁被一个线程以写模式占用的时候，写操作的其他线程会被阻塞，读操作的其他线程也被阻塞。
 
 */
 /*
  // 初始化
  pthread_rwlock_t rwlock = PTHREAD_RWLOCK_INITIALIZER;
  // 写模式
  pthread_rwlock_wrlock(&rwlock);
  // 读模式
  pthread_rwlock_rdlock(&rwlock);
  // 读模式或者写模式的解锁
  pthread_rwlock_unlock(&rwlock);
  // 销毁锁
  pthread_rwlock_destroy(&rwlock);
  */
- (void)threadSafePthread_rwlock{
    rwLock = (pthread_rwlock_t)PTHREAD_RWLOCK_INITIALIZER;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self readBookWithTag:1];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self readBookWithTag:2];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self writeBook:3];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self writeBook:4];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self readBookWithTag:5];
    });
    
}
// 读
- (void)readBookWithTag:(NSInteger )tag {
    pthread_rwlock_rdlock(&rwLock);
    
    NSString *redStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"读：%ld -- %@",tag,redStr);
    
    pthread_rwlock_unlock(&rwLock);
}
// 写
- (void)writeBook:(NSInteger)tag {
    pthread_rwlock_wrlock(&rwLock);

//    NSLog(@"写入文件数据");
    NSString *writeStr = [NSString stringWithFormat:@"tag值为：%ld",tag];
    [writeStr writeToFile:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"txt"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSString *redStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"写入之后读取文件数据：%@",redStr);

    pthread_rwlock_unlock(&rwLock);
}

#pragma mark - POSIX Conditions
/**
 - POSIX条件锁需要互斥锁和条件两项来实现，虽然看起来没什么关系，但在运行时中，互斥锁将会与条件结合起来。线程将被一个互斥和条件结合的信号来唤醒。
 - 首先初始化条件和互斥锁，当 ready_to_go 为 flase 的时候，进入循环，然后线程将会被挂起，直到另一个线程将 ready_to_go 设置为 true 的时候，并且发送信号的时候，该线程会才被唤醒。
 */
- (void)threadSafePOSIXConditions{
    // 条件是否满足标识符，true代表满足
    ready_to_go = true;
    // 初始化锁
    mutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_init(&mutex, NULL);
    // 初始化条件
    pthread_cond_init(&condition, NULL);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self MyWaitOnConditionFunction];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self SignalThreadUsingCondition];
    });
}
- (void)MyWaitOnConditionFunction{
    // 加锁
    pthread_mutex_lock(&mutex);
    // 判断运行条件，如果运行条件不满足，则该线程等待，等待其它线程运行结束，并发出等待信号
    while(ready_to_go == false){
        // 条件不满足，发出线程等待信号
        NSLog(@"MyWait：线程等待");
        pthread_cond_wait(&condition, &mutex);
    }
    NSLog(@"MyWait：开始处理本线程数据");
    ready_to_go = false;
    NSLog(@"MyWait：本线程数据处理结束");
    // 解锁
    pthread_mutex_unlock(&mutex);

}
- (void)SignalThreadUsingCondition{
    pthread_mutex_lock(&mutex);
    NSLog(@"Signal:开始本线程数据处理等操作");
    ready_to_go = true;
    NSLog(@"Signal:本线程数据处理结束");
    // 发送信号让其它线程运行
    pthread_cond_signal(&condition);
    // 解锁
    pthread_mutex_unlock(&mutex);
}
#pragma mark - OSSpinLock
/**
 - 自旋锁：和互斥锁类似，都是为了保证线程安全的锁。
 - 对于互斥锁，当一个线程获得这个锁之后，其他想要获得此锁的线程将会被阻塞，直到该锁被释放。
 - 对于自旋锁，当一个线程获得锁之后，其他线程将会一直循环在哪里查看是否该锁被释放。所以，此锁比较适用于锁的持有者保存时间较短的情况下。
 - 此自旋锁存在优先级反转问题。
- 为了解决 此自旋锁优先级反转问题，在iOS 10.0之后，苹果又整出来个 os_unfair_lock_t，用此来解决优先级反转问题
 */
- (void)threadSafeOSSpinLock{
//    // 初始化
//    OSSpinLock spinLock = OS_SPINLOCK_INIT;
////    // 加锁
//    OSSpinLockLock(&spinLock);
////    // 解锁
//    OSSpinLockUnlock(&spinLock);
    // 使用示例：
    __block OSSpinLock oslock = OS_SPINLOCK_INIT;
    //线程1
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"线程1 准备上锁");
        OSSpinLockLock(&oslock);
//        sleep(4);
        NSLog(@"线程1 正在处理数据");
        OSSpinLockUnlock(&oslock);
        NSLog(@"线程1 解锁成功");
    });
    
    //线程2
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CFTimeInterval start = CFAbsoluteTimeGetCurrent();
        NSLog(@"线程2 准备上锁");
        OSSpinLockLock(&oslock);
        NSLog(@"线程2 正在处理数据");
        CFTimeInterval end = CFAbsoluteTimeGetCurrent();
        OSSpinLockUnlock(&oslock);
        CFTimeInterval cost = start - end; // 验证处理性能
        NSLog(@"线程2 解锁成功 time == %f",cost);
    });
}

#pragma mark - os_unfair_lock
/**
  - 自旋锁
  - 苹果整出来，用此来解决`OSSpinLock`优先级反转问题。
 */
- (void)threadSafeOs_unfair_lock{
//    // 初始化
//    os_unfair_lock_t unfairLock = &(OS_UNFAIR_LOCK_INIT);
//    // 加锁
//    os_unfair_lock_lock(unfairLock);
//    // 解锁
//    os_unfair_lock_unlock(unfairLock);
//    // 尝试加锁  如果返回YES表示已经加锁
//    BOOL isLock = os_unfair_lock_trylock(unfairLock);

    // 使用示例  发现运行报错，还未找出解决方法
//    os_unfair_lock unLock = OS_UNFAIR_LOCK_INIT;
//    __block os_unfair_lock_t unfairLock = &unLock;
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        // 初始化
//        NSLog(@"线程3 开始上锁");
//        if (!os_unfair_lock_trylock(unfairLock)) {
//            os_unfair_lock_lock(unfairLock);
//            NSLog(@"线程3 >>>正在处理数据");
//            os_unfair_lock_unlock(unfairLock);
//            NSLog(@"线程3 解锁成功");
//        }
//
//    });
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"线程4 开始上锁");
//        if (!os_unfair_lock_trylock(unfairLock)) {
//            os_unfair_lock_lock(unfairLock);
//            NSLog(@"线程4 >>>正在处理数据");
//            os_unfair_lock_unlock(unfairLock);
//            NSLog(@"线程4 解锁成功");
//        }
//   });
}

#pragma mark - 信号量
/**
 在GCD中提供了一种信号机制，也可以解决资源抢占问题（和同步锁的机制并不一样)
 GCD中信号量是dispatch_semaphore_t类型，支持信号通知和信号等待。
 每当发送一个信号通知，则信号量+1；每当发送一个等待信号时信号量-1,；如果信号量为0则信号会处于等待状态，直到信号量大于0开始执行。
 根据这个原理我们可以初始化一个信号量变量，默认信号量设置为1，每当有线程进入“加锁代码”之后就调用信号等待命令（此时信号量为0）开始等待，此时其他线程无法进入，执行完后发送信号通知（此时信号量为1），其他线程开始进入执行，如此一来就达到了线程同步目的。
 */
- (void)threadSafeSemaphore{
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
