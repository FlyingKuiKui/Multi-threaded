//
//  NSThreadAndNSObjectViewController.m
//  Multi-threaded
//
//  Created by 王盛魁 on 2017/8/22.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "NSThreadAndNSObjectViewController.h"

@interface NSThreadAndNSObjectViewController ()
@property (nonatomic, strong) NSThread *thread;

@end
/**
   NSThread 是对PThread进行OC层次的封装
     |-->NSThread创建子线程方式一：使用类方法进行创建
     |-->NSThread创建子线程方式二：使用对象方法进行创建
        - (void)cancel; // 取消
        - (void)start;  // 开启

    注意：记得手动启动—只有NSThread需要添加,我们手动开辟的子线程是不会自动添加释放池的,我们需要手动添加自动释放池
 
 
   NSObject 内也存在开辟子线程的方式，因此所有继承NSObject的类均可以使用
 */
@implementation NSThreadAndNSObjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NSThread/NSObject";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self creatThreadWithNSThreadFirst];
    
    [self creatThreadWithNSThreadSecond];
    
    [self creatThreadWithNSObject];
    // Do any additional setup after loading the view.
}
#pragma mark - NSThread
// NSThread创建子线程方式一：使用类方法进行创建
- (void)creatThreadWithNSThreadFirst{
    NSDictionary *dict = @{@"key":@"NSThreadFirst"};
    [NSThread detachNewThreadSelector:@selector(NSThreadFirstFunc:) toTarget:self withObject:dict];
    // ios10.0 之后可以利用block的模式添加子线程
    [NSThread detachNewThreadWithBlock:^{
        BOOL isResult = [NSThread isMultiThreaded];
        NSLog(@"类方式创建-block-当前线程为：%@",isResult?@"子线程":@"主线程");
    }];
}
- (void)NSThreadFirstFunc:(id)argument{
    if ([argument isKindOfClass:[NSDictionary class]]) {
        NSLog(@"key：%@",[argument valueForKey:@"key"]);
    }
    BOOL isResult = [NSThread isMultiThreaded];
    NSLog(@"类方式创建-当前线程为：%@",isResult?@"子线程":@"主线程");
}
// NSThread创建子线程方式二：使用对象方法进行创建
- (void)creatThreadWithNSThreadSecond{
    NSDictionary *dict = @{@"key":@"NSThreadSecond"};
    NSThread *thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(NSThreadSecond:) object:dict];
    // ios10.0 之后，可以利用block进行子线程的创建
    NSThread *thread2 = [[NSThread alloc]initWithBlock:^{
        BOOL isResult = [NSThread isMultiThreaded];
        [NSThread exit]; // 线程强制终止，写在那个子线程方法内，终止哪个子线程
        NSLog(@"对象方法创建-block-当前线程为：%@",isResult?@"子线程":@"主线程");
    }];
    // 线程优先级，值范围0.0~1.0，默认0.5
    thread1.threadPriority = 0.2;
    thread2.threadPriority = 1.0;
    // 对象方式创建子线程，需手动开启线程。
    [thread1 start];
    [thread2 start];
    self.thread = thread1;
}
- (void)NSThreadSecond:(id)argument{
    // 手动开辟的子线程是不会自动添加释放池的，需要手动添加自动释放池
    @autoreleasepool {
        if ([argument isKindOfClass:[NSDictionary class]]) {
            NSLog(@"key：%@",[argument valueForKey:@"key"]);
        }
        // 线程取消
        for (int i = 0; i<2000; i++) {
            NSLog(@"%d",i);
            if (self.thread.cancelled) {
                break;
            }
            if (i == 200) {
                [self.thread cancel];
            }
        }
        BOOL isResult = [NSThread isMultiThreaded];
        NSLog(@"对象方式创建-当前线程为：%@",isResult?@"子线程":@"主线程");
    }
}
#pragma mark - NSObject
// NSObject创建子线程方式
- (void)creatThreadWithNSObject{
    [self performSelectorInBackground:@selector(NSObjectThreadFunc) withObject:nil];
}
- (void)NSObjectThreadFunc{
    // 当程序打开运行时，系统会自动为主线程添加自动释放池，对于子线程需要我们自己添加。
    @autoreleasepool {
        BOOL isResult = [NSThread isMultiThreaded];
        NSLog(@"NSObject方式创建-当前线程为：%@",isResult?@"子线程":@"主线程");
        // 利用子线程处理数据之后，对于界面的刷新以及UI控件的添加显示都在主线程中操作
        [self performSelectorOnMainThread:@selector(NSObjectMainThread) withObject:nil waitUntilDone:YES];
    }
}
- (void)NSObjectMainThread{
    
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
