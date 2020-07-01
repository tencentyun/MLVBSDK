//
//  QCloudModel.h
//  QCloudModel <https://github.com/ibireme/QCloudModel>
//
//  Created by ibireme on 15/5/10.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

#if __has_include(<QCloudCore/QCloudCore.h>)
FOUNDATION_EXPORT double QCloudModelVersionNumber;
FOUNDATION_EXPORT const unsigned char QCloudModelVersionString[];
#import <QCloudCore/NSObject+QCloudModel.h>
#import <QCloudCore/QCloudClassInfo.h>
#else
#import "NSObject+QCloudModel.h"
#import "QCloudClassInfo.h"
#endif
