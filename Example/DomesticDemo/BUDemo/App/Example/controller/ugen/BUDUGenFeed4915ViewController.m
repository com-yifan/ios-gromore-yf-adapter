//
//  BUDUgenStreet3ViewController.m
//  BUDemo
//
//  Created by ByteDance on 2022/9/7.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "BUDUGenFeed4915ViewController.h"
#import "Ugen.h"
@interface BUDUGenFeed4915ViewController ()<UgenEventDelegate>

@property (nonatomic, strong) UgenEngine *ugenEngine;

@end

@implementation BUDUGenFeed4915ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
     
   
    if (![UgenEngine checkValidVersion:[self p_mockTemplate]]) {
        return;
    }
    
    _ugenEngine = [[UgenEngine alloc] initWithContext:self bizId:@"Street3"];
    _ugenEngine.eventDelegate = self;
    UgenTemplateItem *item = [[UgenTemplateItem alloc] init];
    item.templateInfo = [self p_mockTemplate];
    
    [_ugenEngine createViewWithTemplateItem:item
                                    bizData:[self p_mockData]
                                 measureSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - 88)
                                      result:^(NSError * _Nullable error, UgenWidget * _Nullable resultWidget) {
        if (!error && resultWidget.ugenView) {
            [self.view addSubview:resultWidget.ugenView];
        }
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 测试刷新接口
        
    });
}

#pragma mark - UgenEventDelegate
- (void)onUgenEvent:(UgenEvent *)event success:(void (^)(void))success failed:(void (^)(void))failed {
    NSLog(@"lwytest-- 事件类型：%ld", event.type);
    if (event.type == UgenEventType_OnShake) {
        
    } else if (event.type == UgenEventType_OnSlide) {
        
    }
}

#pragma mark - mock


- (NSDictionary *)p_mockTemplate {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ugen_dsl_4915" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return result;
};

- (NSDictionary *)p_mockData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"feed_image_mode3" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return result;
}

@end

