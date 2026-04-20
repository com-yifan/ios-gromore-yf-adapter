//
//  BUDUgenDemoViewController.m
//  BUDemo
//
//  Created by ByteDance on 2022/8/17.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "BUDUGenoDemoViewController.h"
#import "BUDUGenoLUPageViewController.h"
#import "BUDUGenoLUPage2ViewController.h"
#import "BUDUGenoLUPage3ViewController.h"
#import "BUDUGenFeed4627ViewController.h"
#import "BUDUGenFeed4628ViewController.h"
#import "BUDUGenFeed4915ViewController.h"

#import "BUDSlotViewModel.h"
#import "BUDSlotID.h"
#import "BUDActionCellView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImage.h>
#import <AFNetworking/AFURLSessionManager.h>
#import "Ugen.h"

#import "BUDVideoPlayerView.h"
#import "BUDVideoView.h"
#import "NSString+BUAddtion.h"
#import "CSJLottie.h"

@interface CSJImageHandler : UgenImageHandler

@end

@implementation CSJImageHandler

- (void)loadImageWithImageView:(UIImageView *)imageView
                           url:(nullable NSURL *)url
              placeholderImage:(nullable UIImage *)placeholder
                     completed:(nullable UgenImageCompletionBlock)completedBlock {
    [imageView sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (completedBlock) {
            completedBlock(image, error, imageURL);
        }
    }];
  
}

- (void)localImageWithImageView:(UIImageView *)imageView
                           name:(NSString *)name
                      completed:(nullable UgenLocalImageCompletionBlock)completedBlock {
    UIImage *image = [UIImage imageNamed:name];
    if (completedBlock) {
        completedBlock(image, nil);
    }
}

- (void)localGifImageDataWithName:(NSString *)name
                        completed:(UgenGifImageDataCompletionBlock)completedBlock {
    NSData *data = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
    if (path) {
        data = [NSData dataWithContentsOfFile:path];
    }
    if (completedBlock) {
        completedBlock(data, nil);
    }
}

@end

@interface CSJLOTAnimationView()<UgenLottieAnimationProtocol>

@end

@interface CSJLOTComposition ()<UGenLottieCompositionProtocol>

@end

@interface CSJLottieImageCache: NSObject <CSJLOTImageCache>

@end

@implementation CSJLottieImageCache

- (UIImage *)imageForKey:(NSString *)key {
    return [[SDImageCache sharedImageCache] imageFromCacheForKey:key];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    [[SDImageCache sharedImageCache] storeImage:image forKey:key completion:nil];
}

@end

@interface CSJLottieDownlader: NSObject <CSJLOTDownloader>

@end

@implementation CSJLottieDownlader

- (NSString *)fileCacheDirectory {
    NSString *libraryCaches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *sourcesPath = [libraryCaches stringByAppendingPathComponent:@"CSJLottieResources"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:sourcesPath]) {
        [manager createDirectoryAtPath:sourcesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return sourcesPath;
}

- (NSString *)filePathWithKey:(NSString *)key {
    NSString *urlStr = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *urlMd5 = [url.absoluteString bu_MD5HashString];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", urlMd5, url.lastPathComponent];
    NSString *fileDestinationPath = [[self fileCacheDirectory] stringByAppendingPathComponent:fileName];
    return fileDestinationPath;
}

- (void)sessionDownloaderWithURL:(nullable NSURL *)url completion:(nullable CSJLOTDownloadCompletionBlock)completion {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *destinationFilePath = [self filePathWithKey:url.absoluteString];
    if ([fileManager fileExistsAtPath:destinationFilePath]) {
        NSError *error;
        NSData *fileData = [NSData dataWithContentsOfFile:destinationFilePath options:NSDataReadingMappedIfSafe error:&error];
        if (error || fileData == nil) {
            [fileManager removeItemAtPath:destinationFilePath error:nil];
        }
        !completion ?: completion(fileData, error);
        return;
    }
    
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 10.0;
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
    sessionManager.completionQueue = dispatch_queue_create("com.CSJLottieResources.queue", DISPATCH_QUEUE_CONCURRENT);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if (request == nil) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:3000 userInfo:@{NSURLErrorFailingURLErrorKey: @"请求异常"}];
        !completion ?: completion(nil, error);
        return;
    }
    NSURLSessionDownloadTask *downlaodTask = [sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:destinationFilePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(response == nil || filePath == nil || error) {
            !completion ?: completion(nil, error);
            return;
        }
        NSData *downloadData = [NSData dataWithContentsOfURL:filePath options:NSDataReadingMappedIfSafe error:&error];
        
        NSError *jsonError;
        id serializaitonObject = [NSJSONSerialization JSONObjectWithData:downloadData options:NSJSONReadingAllowFragments error:&jsonError];
        if (![NSJSONSerialization isValidJSONObject:serializaitonObject] || jsonError) {
            [fileManager removeItemAtPath:destinationFilePath error:nil];
        }
        !completion ?: completion(downloadData, error);
    }];
    
    [downlaodTask resume];
}

@end


@interface CSJLottieHandler : UgenLottieHandler

@end

@implementation CSJLottieHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        [CSJLOTCacheProvider setImageCache:[CSJLottieImageCache new]];
        [CSJLOTDownloaderProvider setLottieDownloader:[CSJLottieDownlader new]];
    }
    return self;
}

- (UIView<UgenLottieAnimationProtocol> *)lottieView {
    return [[CSJLOTAnimationView alloc] init];
}

- (void)animationWithContentsOfURL:(NSURL *)url completed:(UgenLottieCompositionCompletionBlock)completedBlock {
    if (url == nil) {
        !completedBlock ?: completedBlock(nil);
        return;
    }

    CSJLOTComposition *composition = [CSJLOTComposition animationWithContentsOfURL:url completion:^(CSJLOTComposition * _Nullable composition) {
        !completedBlock ?: completedBlock(composition);
    }];
}

- (void)animationWithName:(NSString *)name inBundle:(NSBundle *)bundle completed:(UgenLottieCompositionCompletionBlock)completedBlock {
    if (name.length == 0) {
        !completedBlock ?: completedBlock(nil);
        return;
    }
    
    CSJLOTComposition *composition = nil;
    if (bundle == nil) {
        composition = [CSJLOTComposition animationNamed:name inBundle:bundle];
    } else {
        composition = [CSJLOTComposition animationNamed:name inBundle:bundle];
    }
    
    if (completedBlock) {
        completedBlock(composition);
    }
}

- (void)animationWithJSON:(NSDictionary *)json inBundle:(NSBundle *)bundle completed:(UgenLottieCompositionCompletionBlock)completedBlock {
    if (json.count == 0) {
        !completedBlock ?: completedBlock(nil);
        return;
    }
    
    CSJLOTComposition *composition = nil;
    if (bundle == nil) {
        composition = [CSJLOTComposition animationFromJSON:json];
    } else {
        composition = [CSJLOTComposition animationFromJSON:json inBundle:bundle];
    }
    if (completedBlock) {
        completedBlock(composition);
    }
}

- (void)animationWithFilepath:(NSString *)filePath completed:(UgenLottieCompositionCompletionBlock)completedBlock {
    if (filePath.length == 0) {
        !completedBlock ?: completedBlock(nil);
        return;
    }
    
    CSJLOTComposition *composition = [CSJLOTComposition animationWithFilePath:filePath];
    if (completedBlock) {
        completedBlock(composition);
    }
}

@end

// 自定义组件
@interface DislikeComponent : UgenWidget

@end

@implementation DislikeComponent

- (void)render {
    
}

- (void)bindAttributeValue:(id)value forKey:(NSString *)key {
    
}

@end

// 自定义组件
@interface VideoComponent : UgenWidget

@end

@interface VideoComponent ()

@property (nonatomic, strong) BUDVideoPlayerView *adView;
@property (nonatomic, copy) NSString *src;
@property (nonatomic, copy) NSString *coverSrc;

@end

@implementation VideoComponent

- (instancetype)init {
    self = [super init];
    if (self) {
        BUDVideoPlayerView *adView = [[BUDVideoPlayerView alloc] initWithFrame:CGRectZero];
        self.adView = adView;
       // [self.adView.videoView addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (UIView *)ugenView {
    return self.adView;
}

- (void)render {
    [super render];
    [self showAd];
    
    
}

- (void)bindAttributeValue:(id)value forKey:(NSString *)key {
    [super bindAttributeValue:value forKey:key];
   
}

- (void)showAd {
    
    BUSize *imgSize1 = [[BUSize alloc] init];
    imgSize1.width = 1080;
    imgSize1.height = 1920;
    
    BUAdSlot *slot1 = [[BUAdSlot alloc] init];
    slot1.ID = @"900546829";
  //  slot1.AdType = BUAdSlotAdTypeInterstitial;
    slot1.imgSize = imgSize1;
    slot1.supportRenderControl = YES;
    slot1.adSize = CGSizeMake(300, 300);
    
    BUNativeAd *ad = [[BUNativeAd alloc] initWithSlot:slot1];
    
    [ad registerContainer:self.adView withClickableViews:nil];
   // ad.rootViewController = self;
    // 核心代码
    NSString *url = self.src;
    if (url.length) {
        [self.adView refreshUIWithUrl:url];
        [self.adView sizeToFit];
    }
}

@end


// 自定义布局方式
@interface AutoLayoutWidget : UgenWidget

@end

@implementation AutoLayoutWidget

- (void)render {
    
}

- (void)bindAttributeValue:(id)value forKey:(NSString *)key {
    
}

- (void)addwidget:(UgenWidget *)widget {
    
}

@end


@implementation BUDUGenoDemoViewController


- (instancetype)init {
    self = [super init];
    if (self) {
        [[UgenEnv sharedInstance] registerBehaviorBundle:[[UgenBehaviorBundle alloc] initWithBehaviors:^{
            return @[
                // 自定义注册图片加载
                [[UgenBehavior alloc] initWithImageHandler:^{
                    return [[CSJImageHandler alloc] init];
                }],
                [[UgenBehavior alloc] initWithLottieHandler:^UgenLottieHandler * _Nonnull{
                    return [[CSJLottieHandler alloc] init];
                }],
                // 自定义注册组件
                [[UgenBehavior alloc] initWithName:@"dislike" widget:^{
                    return [[DislikeComponent alloc] init];
                }],
                [[UgenBehavior alloc] initWithName:@"Video" widget:^{
                    return [[VideoComponent alloc] init];
                }],
                // 自定义注册布局
                [[UgenBehavior alloc] initWithName:@"autoLayout" widget:^{
                    return [[AutoLayoutWidget alloc] init];
                }]
            ];
        }]];
    }
    return self;
}

- (NSArray<NSArray<BUDActionModel *> *> *)itemsForList {
    __weak typeof(self) weakSelf = self;
    
    BUDActionModel *nativeCell1Item = [BUDActionModel plainTitleActionModel:[NSString localizedStringForKey:kUgenoLUPage] type:BUDCellType_native action:^{
        __strong typeof(weakSelf) self = weakSelf;
        BUDUGenoLUPageViewController *vc = [BUDUGenoLUPageViewController new];
        BUDSlotViewModel *viewModel = [BUDSlotViewModel new];
        viewModel.slotID = native_feed_custom_player_ID;
        vc.viewModel = viewModel;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    BUDActionModel *nativeCell1_2Item = [BUDActionModel plainTitleActionModel:[NSString localizedStringForKey:kUgenoLUPage2] type:BUDCellType_native action:^{
        __strong typeof(weakSelf) self = weakSelf;
        BUDUGenoLUPage2ViewController *vc = [BUDUGenoLUPage2ViewController new];
        BUDSlotViewModel *viewModel = [BUDSlotViewModel new];
        viewModel.slotID = native_feed_custom_player_ID;
        vc.viewModel = viewModel;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    BUDActionModel *nativeCell1_3Item = [BUDActionModel plainTitleActionModel:[NSString localizedStringForKey:kUgenoLUPage3] type:BUDCellType_native action:^{
        __strong typeof(weakSelf) self = weakSelf;
        BUDUGenoLUPage3ViewController *vc = [BUDUGenoLUPage3ViewController new];
        BUDSlotViewModel *viewModel = [BUDSlotViewModel new];
        viewModel.slotID = native_feed_custom_player_ID;
        vc.viewModel = viewModel;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    BUDActionModel *nativeCell2_1Item = [BUDActionModel plainTitleActionModel:[NSString localizedStringForKey:kUgenoStreet1] type:BUDCellType_native action:^{
        __strong typeof(weakSelf) self = weakSelf;
        BUDUGenFeed4627ViewController *vc = [BUDUGenFeed4627ViewController new];
        BUDSlotViewModel *viewModel = [BUDSlotViewModel new];
        viewModel.slotID = native_feed_custom_player_ID;
        vc.viewModel = viewModel;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    BUDActionModel *nativeCell2_2Item = [BUDActionModel plainTitleActionModel:[NSString localizedStringForKey:kUgenoStreet2] type:BUDCellType_native action:^{
        __strong typeof(weakSelf) self = weakSelf;
        BUDUGenFeed4628ViewController *vc = [BUDUGenFeed4628ViewController new];
        BUDSlotViewModel *viewModel = [BUDSlotViewModel new];
        viewModel.slotID = native_feed_custom_player_ID;
        vc.viewModel = viewModel;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    BUDActionModel *nativeCell2_3Item = [BUDActionModel plainTitleActionModel:[NSString localizedStringForKey:kUgenoStreet3] type:BUDCellType_native action:^{
        __strong typeof(weakSelf) self = weakSelf;
        BUDUGenFeed4915ViewController *vc = [BUDUGenFeed4915ViewController new];
        BUDSlotViewModel *viewModel = [BUDSlotViewModel new];
        viewModel.slotID = native_feed_custom_player_ID;
        vc.viewModel = viewModel;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    return @[@[nativeCell1Item, nativeCell1_2Item, nativeCell1_3Item, nativeCell2_1Item, nativeCell2_2Item, nativeCell2_3Item]];
}

@end
