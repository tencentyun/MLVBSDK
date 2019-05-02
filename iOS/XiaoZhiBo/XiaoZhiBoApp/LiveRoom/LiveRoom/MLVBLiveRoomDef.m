//
//  RoomDef.m
//  TXLiteAVDemo
//
//  Created by lijie on 2017/11/21.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "MLVBLiveRoomDef.h"

@implementation MLVBLoginInfo
- (instancetype)copyWithZone:(NSZone *)zone
{
    MLVBLoginInfo *loginInfo = [[MLVBLoginInfo alloc] init];
    loginInfo.userID     = self.userID;
    loginInfo.userName   = self.userName;
    loginInfo.userAvatar = self.userAvatar;
    loginInfo.sdkAppID   = self.sdkAppID;
    loginInfo.userSig    = self.userSig;
    return loginInfo;
}
@end

@implementation MLVBAnchorInfo
- (BOOL)isEqual:(MLVBAnchorInfo *)object {
    if (object == nil) return NO;
    if (![object isKindOfClass:[MLVBAnchorInfo class]]) return NO;
    return self.userID == object.userID || [self.userID isEqualToString:object.userID];
}
- (NSString *)description {
    return [NSString stringWithFormat:@"userID[%@] accelerateURL:[%@]", _userID, _accelerateURL];
}
@end

@implementation MLVBAudienceInfo
- (BOOL)isEqual:(MLVBAudienceInfo *)object {
    if (object == nil) return NO;
    if (![object isKindOfClass:[MLVBAudienceInfo class]]) return NO;
    return self.userID == object.userID || [self.userID isEqualToString:object.userID];
}

- (void)setUserInfo:(NSString *)userInfo {
    if (_userInfo == userInfo) return;
    _userInfo = userInfo;
    if (userInfo.length > 0) {
        NSData *data = [userInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([jsonDict isKindOfClass:[NSDictionary class]]) {
            _userName = jsonDict[@"userName"];
            _userAvatar = jsonDict[@"userAvatar"];
        }
    }
}

@end

@implementation MLVBRoomInfo
- (instancetype)init {
    if (self = [super init]) {
        _anchorInfoArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"roomID[%@] roomName[%@] roomCreator[%@] mixedPlayURL[%@] anchorInfoArray[%@]", _roomID, _roomInfo, _roomCreator, _mixedPlayURL, _anchorInfoArray];
}
@end
