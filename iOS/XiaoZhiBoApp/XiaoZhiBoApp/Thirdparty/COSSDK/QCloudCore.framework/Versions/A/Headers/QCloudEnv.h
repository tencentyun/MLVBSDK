//
//  QCloudEnv.h
//  QCloudTernimalLab_CommonLogic
//
//  Created by tencent on 16/2/26.
//  Copyright © 2016年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, QCloudEnviroment) {
    QCloudNormalEnviroment = 0,
    QCloudDebugEnviroment = 1,
    QCloudTestEnviroment = 2,
};
/**
   判断当前是否是正式环境
 */
#define IS_QCloud_NORMAL_ENV __IS_QCloud_NORMAL_ENV()
/**
   判断当前是否是测试环境
 */
#define IS_QCloud_TEST_ENV __IS_QCloud_TEST_ENV()

/**
 * 判断当前是否是开发环境
 */
#define IS_QCloud_DEBUG_ENV __IS_QCloud_DEBUG_ENV()

FOUNDATION_EXTERN BOOL __IS_QCloud_NORMAL_ENV(void);
FOUNDATION_EXTERN BOOL __IS_QCloud_TEST_ENV(void);
FOUNDATION_EXTERN BOOL __IS_QCloud_DEBUG_ENV(void);

/**
   切换网络环境
      @param env 网络环境
 */
void QCloudChangeGlobalEnviroment(QCloudEnviroment env);
