//
//  PThreadViewController.m
//  Multi-threaded
//
//  Created by 王盛魁 on 2017/8/22.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "PThreadViewController.h"
#import <pthread.h>  // 导入此框架，验证PThread
@interface PThreadViewController ()

@end
/**
  PThread：
  C语言版的简单的开辟子线程
 */
@implementation PThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PThread";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self creatThreadWithPThread];
    
    
    // Do any additional setup after loading the view.
}
#pragma mark - PThread
// 开辟子线程的方式：
- (void)creatThreadWithPThread{
    pthread_t thread1;
    NSString *identification = @"threadOne"; // 线程标识符
    // (__bridge void *)(identification) 将OC的id类型转化为 void* 类型
    pthread_create(&thread1, NULL, threadFunc, (__bridge void *)(identification));
    // 参数一：线程变量；参数二：线程属性，这里没有进行设定；参数三：子线程将要执行的方法；参数四：执行方法传递的参数，这里传递的是线程标识符，
    // thread1	pthread_t	0x70000ad70000	0x000070000ad70000
    
}
// 线程将要执行的方法
void *threadFunc(void *paragram){
    BOOL isResult = [[NSThread currentThread]isMainThread];
    // (__bridge NSString *)(paragram) 将void*类型转化为OC的id类型
    NSLog(@"传递的标识符为：%@",(__bridge NSString *)(paragram));
    NSLog(@"当前线程为：%@",isResult?@"主线程":@"子线程");
    pthread_t thisThrad = pthread_self();
    // thisThrad	pthread_t	0x70000ad70000	0x000070000ad70000
    pthread_cancel(thisThrad);
    NSLog(@"-这句话执行不到-");
    return NULL;
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
