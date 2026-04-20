//
//  BUDUGenFeed4627ViewController.m
//  BUDemo
//
//  Created by ByteDance on 2022/8/24.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "BUDUGenFeed4627ViewController.h"
#import "Ugen.h"

@interface BUDUGenFeed4627ViewController ()<UgenTemplateDataSource>

@property (nonatomic, strong) UgenEngine *ugenoEngine;

@end


@implementation BUDUGenFeed4627ViewController

- (instancetype)init {
    self = [super init];
    if (self) {
  
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor lightGrayColor];
    
    if (![UgenEngine checkValidVersion:[self p_mockTemplate]]) {
        return;
    }
    
    _ugenoEngine = [[UgenEngine alloc] initWithContext:self bizId:@"Street1"];
    
    UgenTemplateItem *item = [[UgenTemplateItem alloc] init];
    item.templateInfo = [self p_mockTemplate];
    item.dataSource = self;
    [_ugenoEngine createViewWithTemplateItem:item
                                     bizData:[self p_mockData]
                                 measureSize:self.view.bounds.size
                                      result:^(NSError * _Nullable error, UgenWidget * _Nullable resultWidget) {
        if (!error && resultWidget.ugenView) {
            [self.view addSubview:resultWidget.ugenView];
        }
    }];
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


#pragma mark - mock


- (NSDictionary *)p_mockTemplate {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ugen_dsl_4627" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return result;
};

// 直播
- (NSDictionary *)p_mockData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"feed_image_mode3" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return result;
}

@end


