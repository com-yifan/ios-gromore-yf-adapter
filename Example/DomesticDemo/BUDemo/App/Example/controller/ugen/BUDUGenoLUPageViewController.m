//
//  BUDUGenoLUPageViewController.m
//  BUDemo
//
//  Created by ByteDance on 2022/8/17.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "BUDUGenoLUPageViewController.h"
#import "Ugen.h"

@interface BUDUGenoLUPageViewController ()<UgenTemplateDataSource, UgenEventDelegate, UgenTrackerDelegate>

@property (nonatomic, strong) UgenEngine *ugenEngine;

@end

@implementation BUDUGenoLUPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    if (![UgenEngine checkValidVersion:[self p_mockTemplate]]) {
        return;
    }
    
    _ugenEngine = [[UgenEngine alloc] initWithContext:self bizId:@"LUPage1"];
    _ugenEngine.eventDelegate = self;
    _ugenEngine.trackerDelegate = self;
    UgenTemplateItem *item = [[UgenTemplateItem alloc] init];
    item.templateInfo = [self p_mockTemplate];
    item.dataSource = self;

    [_ugenEngine createViewWithTemplateItem:item
                                    bizData:[self p_mockData]
                                 measureSize:self.view.bounds.size
                                      result:^(NSError * _Nullable error, UgenWidget * _Nullable resultWidget) {
        if (!error && resultWidget.ugenView) {
            [self.view addSubview:resultWidget.ugenView];
        }
    }];
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 测试刷新接口
        
    });
}

#pragma mark - UGenoTemplateDataSource
- (NSString *)subTemplateIdWithDataInfo:(NSDictionary *)dataInfo {
    NSString *subTemplateId = @"";
    if ([dataInfo[@"image_mode"] integerValue] == 15 || [dataInfo[@"image_mode"] integerValue] == 16) {
        // 采用模版id: lu_v
        subTemplateId = @"lu_v";
    } else if ([dataInfo[@"image_mode"] integerValue] == 3 || [dataInfo[@"image_mode"] integerValue] == 5) {
        // 采用模版id: lu_h
        subTemplateId = @"lu_h";
    }
    return subTemplateId;
}

#pragma mark - UgenEventDelegate
- (void)onUgenEvent:(UgenEvent *)event success:(void (^)(void))success failed:(void (^)(void))failed {
    if (event.type == UgenEventType_OnLoadMore) {
        // 追加数据
       // [_ugenEngine appendWithDataList:@[[self p_mockDataList][0], [self p_mockDataList][1]]];
    }
}


#pragma mark - UgenTrackerDelegate
- (void)onTemplateParseBegin:(UgenTracker *)tracker engine:(UgenEngine *)engine {
    
}

- (void)onTemplateParseEnd:(UgenTracker *)tracker engine:(UgenEngine *)engine {
    
}

- (void)onTemplateRenderBegin:(UgenTracker *)tracker engine:(UgenEngine *)engine {
    
}

- (void)onTemplateRenderEnd:(UgenTracker *)tracker engine:(UgenEngine *)engine {
    
}

#pragma mark - mock

- (NSDictionary *)p_mockTemplate {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ugeno_lu_page_template01" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return result;
};


- (NSArray *)p_mockDataList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ugeno_lu_page_data01" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
    return result;
    
}

- (NSDictionary *)p_mockData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ugeno_lu_page_data01" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return result;
}




@end

