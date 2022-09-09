//
//  ViewController.m
//  DispatchGroupCrashDemo
//
//  Created by 心檠 on 2022/9/9.
//

#import "ViewController.h"

@interface ViewController ()

// 强引用group对象
@property (nonatomic, strong) dispatch_group_t group;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) BOOL stopped;

@property (nonatomic, strong) UIButton *convertButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.stopped = YES;
    [self.view addSubview:self.convertButton];
}

static NSInteger taskIndex = 0;

- (void)cancel {
    self.stopped = YES;
    NSLog(@"取消任务");
    [self.queue cancelAllOperations];
}

- (void)exortImage:(NSArray<NSString *> *)infos {
    self.group = dispatch_group_create();
    self.stopped = NO;
    
    __weak typeof(self) weak_self = self;
    for (NSString *info in infos) {
        dispatch_group_enter(self.group);
        NSLog(@"发起任务：%@", info);
        [self.queue addOperationWithBlock:^{
            // 大量计算与io耗时操作
            // ...
            [NSThread sleepForTimeInterval:8];
            NSLog(@"完成任务：%@", info);
            dispatch_group_leave(weak_self.group);
        }];
    }
    dispatch_group_notify(self.group, dispatch_get_main_queue(), ^{
        if (!weak_self.stopped) {
            // 导出完成，下一步
            NSLog(@"顺利完成任务");
        }
    });
}

- (void)onButtonClicked:(UIButton *)button {
    _stopped = !_stopped;
    button.selected = !_stopped;
    if (_stopped) {
        [self cancel];
    } else {
        taskIndex++;
        NSMutableArray *taskIdentifiers = [NSMutableArray array];
        for (NSInteger i = 0; i < 4; i++) {
            [taskIdentifiers addObject:[NSString stringWithFormat:@"任务%ld_子图%ld", taskIndex, i]];
        }
        [self exortImage:taskIdentifiers];
    }
}

- (UIButton *)convertButton {
    if (!_convertButton) {
        _convertButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _convertButton.frame = CGRectMake(200, 200, 80, 40);
        [_convertButton setTitle:@"启动" forState:UIControlStateNormal];
        [_convertButton setTitle:@"停止" forState:UIControlStateSelected];
        [_convertButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_convertButton addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _convertButton;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 2;
    }
    return _queue;
}

@end
