//
//  MaterialManager.m
//  PituMotionDemo
//
//  Created by billwang on 16/8/8.
//  Copyright © 2016年 Pitu. All rights reserved.
//

#import "MaterialManager.h"
#import "MCPackageDownloadTask.h"

#define video_3DFace_alalei0 @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_3DFace_alalei0.zip"

#define video_3DFace_dogglasses2 @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_3DFace_dogglasses2.zip"

#define video_baby_agetest @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_baby_agetest.zip"

#define video_caidai_iOS @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_caidai_iOS.zip"

#define video_huaxianzi @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_huaxianzi.zip"

#define video_liuhaifadai @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_liuhaifadai.zip"

#define video_nihongshu @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_nihongshu.zip"

#define video_rainbow @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_rainbow.zip"

#define video_xiaofu @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_xiaofu.zip"

#define video_boom @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_boom.zip"

#define video_fengkuangdacall @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_fengkuangdacall.zip"

#define video_purplecat @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_purplecat.zip"

#define video_Qxingzuo_iOS @"https://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_Qxingzuo_iOS.zip"

static NSMutableArray *_motionArray;
static NSMutableDictionary *_motionAddressDic;

@implementation MaterialManager

+ (NSArray *)motionArray
{
    if (!_motionArray) {
        _motionArray = [[NSMutableArray alloc] init];
        [_motionArray addObject:@"video_nihongshu"];
        [_motionArray addObject:@"video_3DFace_dogglasses2"];
        [_motionArray addObject:@"video_fengkuangdacall"];
        [_motionArray addObject:@"video_Qxingzuo_iOS"];
        [_motionArray addObject:@"video_caidai_iOS"];
        [_motionArray addObject:@"video_liuhaifadai"];
        [_motionArray addObject:@"video_boom"];
        [_motionArray addObject:@"video_3DFace_alalei0"];
        [_motionArray addObject:@"video_rainbow"];
        [_motionArray addObject:@"video_purplecat"];
        [_motionArray addObject:@"video_huaxianzi"];
        [_motionArray addObject:@"video_baby_agetest"];
        
        _motionAddressDic = [[NSMutableDictionary alloc] init];
        [_motionAddressDic setObject:video_3DFace_alalei0 forKey:@"video_3DFace_alalei0"];
        [_motionAddressDic setObject:video_3DFace_dogglasses2 forKey:@"video_3DFace_dogglasses2"];
        [_motionAddressDic setObject:video_baby_agetest forKey:@"video_baby_agetest"];
        [_motionAddressDic setObject:video_caidai_iOS forKey:@"video_caidai_iOS"];
        [_motionAddressDic setObject:video_huaxianzi forKey:@"video_huaxianzi"];
        [_motionAddressDic setObject:video_liuhaifadai forKey:@"video_liuhaifadai"];
        [_motionAddressDic setObject:video_nihongshu forKey:@"video_nihongshu"];
        [_motionAddressDic setObject:video_rainbow forKey:@"video_rainbow"];
        [_motionAddressDic setObject:video_boom forKey:@"video_boom"];
        [_motionAddressDic setObject:video_fengkuangdacall forKey:@"video_fengkuangdacall"];
        [_motionAddressDic setObject:video_purplecat forKey:@"video_purplecat"];
        [_motionAddressDic setObject:video_Qxingzuo_iOS forKey:@"video_Qxingzuo_iOS"];
    }
    return _motionArray;
}

+ (NSString *)getMotionName:(NSString *)motion
{
    return @""; //暂不展示name
//    if ([motion isEqualToString:@"video_boom"]) {
//        return @"Boom";
//    }
//    else if ([motion isEqualToString:@"video_nihongshu"]){
//        return @"霓虹鼠";
//    }
//    else if ([motion isEqualToString:@"video_3DFace_dogglasses2"]){
//        return @"眼镜狗";
//    }
//    else if ([motion isEqualToString:@"video_fengkuangdacall"]){
//        return @"疯狂打call";
//    }
//    else if ([motion isEqualToString:@"video_Qxingzuo_iOS"]){
//        return @"Q星座";
//    }
//    else if ([motion isEqualToString:@"video_caidai_iOS"]){
//        return @"彩色丝带";
//    }
//    else if ([motion isEqualToString:@"video_liuhaifadai"]){
//        return @"刘海发带";
//    }
//    else if ([motion isEqualToString:@"video_3DFace_alalei0"]){
//        return @"阿拉蕾";
//    }
//    else if ([motion isEqualToString:@"video_rainbow"]){
//        return @"彩虹云";
//    }
//    else if ([motion isEqualToString:@"video_purplecat"]){
//        return @"紫色小猫";
//    }
//    else if ([motion isEqualToString:@"video_huaxianzi"]){
//        return @"花仙子";
//    }
//    else if ([motion isEqualToString:@"video_baby_agetest"]){
//        return @"小公举";
//    }
//    else if ([motion isEqualToString:@"video_xiaofu"]){
//        return @"AI抠背";
//    }
//    else if (motion == nil)
//        return @"无动效";
//    return motion;
}

+ (NSArray *)materialIDs {
    NSArray *materials = @[@"video_fox_iOS",
                           @"video_winter_cat_iOS",
                           @"video_cats_iOS",
                           @"video_aixin_iOS",
                           @"video_guangmao_iOS",
                           // @"video_handpaintcat_iOS",
                           @"video_heart_eye_iOS",
                           @"video_zuanshitu_iOS",
                           @"video_tuzi_iOS",
                           @"video_maonv_iOS",
                           @"video_totoro_iOS",
                           @"video_pig_iOS",
                           @"video_dahuzi_iOS",
                           @"video_gentleman_iOS",
                           @"video_water_ghost_iOS",
                           @"video_lamb_iOS",
                           @"video_xiaohuzi_iOS",
                           @"video_xiaocaiyi_iOS",
                           @"video_lovely_eye_iOS",
                           @"video_guangxiong_iOS",
                           @"video_huangguan_iOS",
                            // 旧资源
                           // @"video_jinmao_iOS",
                           // @"video_fenlu_iOS",
                           // @"video_leipen_iOS",
                           // @"video_nethot_iOS",
                           @"video_zhinv_iOS",
                           @"video_jiaban_dog_iOS",
                           @"video_little_mouse_iOS",
                           @"video_520_iOS",
                           // @"video_zhipai_iOS",
                           @"video_cangshu_iOS",
                           // @"video_huaduo_iOS",
//                           @"video_faceoffablum_iOS",
                           @"video_wawalian_iOS",
                           @"video_aliens_iOS",
                           @"video_fangle2_iOS",
                           // @"video_monalisa_iOS",
                           // @"video_kangxi_iOS",
                           // @"video_angrybird_iOS",
                           // @"video_baby_milk_iOS",
                           // @"video_dayuhaitang_iOS",
                           @"video_fawn_iOS",
                           @"video_guiguan_iOS",
                           @"video_heart_lips_iOS",
                           @"video_laughday_iOS",
                           @"video_cat_iOS",
                           @"video_raccoon_iOS",
                           @"video_liaomei_iOS",
                           @"video_limao_iOS",
                           @"video_lovely_cat_iOS",
                           @"video_molihuaxian_iOS",
                           @"video_mothersday_iOS",
                           @"video_ogle_iOS",
                           @"video_ruhua_iOS",
                           @"video_snake_face_iOS",
                           @"video_zhenzi_iOS",
                           @"video_xiaoxuesheng_iOS",
                           @"video_xinqing_iOS",
                           @"video_cheek_heart_iOS",
                           @"video_heart_cheek_iOS",
                           @"video_yellow_dog_iOS"];
    return materials;
}

+ (NSString *)thumbUrl:(NSString *)materialID {
    NSString *thumbUrl = [NSString stringWithFormat:@"https://st1.xiangji.qq.com/yunmaterials/%@.png", materialID];
    return thumbUrl;
}

+ (NSString *)packageUrl:(NSString *)materialID {
    if ([_motionAddressDic valueForKey:materialID])
        return _motionAddressDic[materialID];
    
    NSString *packageUrl = [NSString stringWithFormat:@"https://st1.xiangji.qq.com/yunmaterials/%@.zip", materialID];
    return packageUrl;
}

+ (NSString *)packageDownloadDir {
    NSString *packageDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/packages"];
    return packageDir;
}
+ (NSString *)packageDownloadDir:(NSString *)materialID {
    NSString *packageDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/packages"];
    NSString *packagePath = [packageDir stringByAppendingPathComponent:materialID];
    return packagePath;
}

+ (BOOL)packageDownloaded:(NSString *)materialID {
    BOOL isOnlinePackage = [self isOnlinePackage:materialID];
    if (isOnlinePackage) {
        NSString *packagePath = [self packageDownloadDir:materialID];
        BOOL isDirectory;
        BOOL packageExists = [[NSFileManager defaultManager] fileExistsAtPath:packagePath isDirectory:&isDirectory];
        return packageExists && isDirectory;
    } else {
        return YES;
    }
}

+ (BOOL)isOnlinePackage:(NSString *)materialID {
    BOOL isOnlinePackage = NO;
    NSArray *materials = [self motionArray]; //[self materialIDs];
    for (NSString *mid in materials) {
        if ([mid isEqualToString:materialID]) {
            isOnlinePackage = YES;
            break;
        }
    }
    return isOnlinePackage;
}

+ (MaterialManager *)shareInstance {
    static MaterialManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MaterialManager alloc] init];
    });
    
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.packageDownloadTasks = [[NSMutableDictionary alloc] init];
        [[NSFileManager defaultManager] createDirectoryAtPath:[self.class packageDownloadDir] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return self;
}

- (BOOL)downloadPackage:(NSString *)materialID {
    NSString *packageUrl = [self.class packageUrl:materialID];
    if (packageUrl) {
        NSURL *downloadURL = [NSURL URLWithString:packageUrl];
        if (downloadURL) {
            if ([self.packageDownloadTasks objectForKey:materialID]) {
                return YES;
            }
            
            __weak MaterialManager *weakSelf = self;
            MCPackageDownloadTask *task = [[MCPackageDownloadTask alloc] initWithPackageID:materialID
                                                                                packageURL:downloadURL
                                                                                  unzipDir:[self.class packageDownloadDir]
               success:^(id<MCPkgDownloadTaskProtocol> task, NSString *packageID, long long totalBytes) {
                   [weakSelf.packageDownloadTasks removeObjectForKey:packageID];
                   
                   // 发送下载成功通知
                   NSDictionary *progressDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                materialID,kMC_USERINFO_ONLINEMANAGER_PACKAGE_MATERIALID,
                                                [NSNumber numberWithFloat:1],kMC_USERINFO_ONLINEMANAGER_PACKAGE_PROGRESS,
                                                nil];
                   [[NSNotificationCenter defaultCenter] postNotificationName:kMC_NOTI_ONLINEMANAGER_PACKAGE_PROGRESS object:progressDic];
               }
               failure:^(id<MCPkgDownloadTaskProtocol> task, NSString *packageID, NSError *error) {
                   [weakSelf.packageDownloadTasks removeObjectForKey:packageID];
                   
                   // 发送下载失败通知
                   NSDictionary *progressDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                materialID,kMC_USERINFO_ONLINEMANAGER_PACKAGE_MATERIALID,
                                                [NSNumber numberWithFloat:0],kMC_USERINFO_ONLINEMANAGER_PACKAGE_PROGRESS,
                                                nil];
                   [[NSNotificationCenter defaultCenter] postNotificationName:kMC_NOTI_ONLINEMANAGER_PACKAGE_PROGRESS object:progressDic];
                   
                   NSLog(@"package(%@) download failed", materialID);
               }
              progress:^(id<MCPkgDownloadTaskProtocol> task, NSString *packageID, float progress) {
                  if (progress > 0.f && progress < 1.f) {
                      // 发送下载进度通知
                      NSDictionary *progressDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   materialID,kMC_USERINFO_ONLINEMANAGER_PACKAGE_MATERIALID,
                                                   [NSNumber numberWithFloat:progress],kMC_USERINFO_ONLINEMANAGER_PACKAGE_PROGRESS,
                                                   nil];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kMC_NOTI_ONLINEMANAGER_PACKAGE_PROGRESS object:progressDic];
                  }
              }];
            [task start];
            [self.packageDownloadTasks setObject:task forKey:materialID];
            
            // 立即回调一个进度信息让菊花转起来
            NSDictionary *progressDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         materialID,kMC_USERINFO_ONLINEMANAGER_PACKAGE_MATERIALID,
                                         [NSNumber numberWithFloat:0.01f],kMC_USERINFO_ONLINEMANAGER_PACKAGE_PROGRESS,
                                         nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMC_NOTI_ONLINEMANAGER_PACKAGE_PROGRESS object:progressDic];
            
            return YES;
        }
    }
    return NO;
}

@end
