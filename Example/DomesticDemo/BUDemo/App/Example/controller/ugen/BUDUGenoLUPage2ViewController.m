//
//  BUDUGenoLUPage2ViewController.m
//  BUDemo
//
//  Created by Rush.D.Xzj on 2022/9/1.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "BUDUGenoLUPage2ViewController.h"
#import "Ugen.h"

@interface BUDUGenoLUPage2ViewController ()<UgenTemplateDataSource>

@property (nonatomic, strong) UgenEngine *ugenoEngine;
@end

@implementation BUDUGenoLUPage2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];
    
    if (![UgenEngine checkValidVersion:[self p_mockTemplate]]) {
        return;
    }
    
    _ugenoEngine = [[UgenEngine alloc] initWithContext:self bizId:@"LUPage2"];
    
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

// image_mode = 3(图片卡片)
- (NSDictionary *)p_mockTemplate {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ugeno_lu_page_template02" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return result;
};


- (NSDictionary *)p_mockData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ugeno_lu_page_data02" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return result;
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
