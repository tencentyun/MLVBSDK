//QCloudUICKeyChainStoreErrorCode//
//  QCloudUICKeyChainStore.h
//  QCloudUICKeyChainStore
//
//  Created by Kishikawa Katsumi on 11/11/20.
//  Copyright (c) 2011 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !__has_feature(nullability)
#define NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_END
#define nullable
#define nonnull
#define null_unspecified
#define null_resettable
#define __nullable
#define __nonnull
#define __null_unspecified
#endif

#if __has_extension(objc_generics)
#define UIC_KEY_TYPE <NSString *>
#define UIC_CREDENTIAL_TYPE <NSDictionary <NSString *, NSString *>*>
#else
#define UIC_KEY_TYPE
#define UIC_CREDENTIAL_TYPE
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString * const QCloudUICKeyChainStoreErrorDomain;

typedef NS_ENUM(NSInteger, QCloudUICKeyChainStoreErrorCode) {
    UICKeyChainStoreErrorInvalidArguments = 1,
};

typedef NS_ENUM(NSInteger, QCloudUICKeyChainStoreItemClass) {
    QCloudUICKeyChainStoreItemClassGenericPassword = 1,
    QCloudUICKeyChainStoreItemClassInternetPassword,
};

typedef NS_ENUM(NSInteger, QCloudUICKeyChainStoreProtocolType) {
    QCloudUICKeyChainStoreProtocolTypeFTP = 1,
    QCloudUICKeyChainStoreProtocolTypeFTPAccount,
    QCloudUICKeyChainStoreProtocolTypeHTTP,
    QCloudUICKeyChainStoreProtocolTypeIRC,
    QCloudUICKeyChainStoreProtocolTypeNNTP,
    QCloudUICKeyChainStoreProtocolTypePOP3,
    QCloudUICKeyChainStoreProtocolTypeSMTP,
    QCloudUICKeyChainStoreProtocolTypeSOCKS,
    QCloudUICKeyChainStoreProtocolTypeIMAP,
    QCloudUICKeyChainStoreProtocolTypeLDAP,
    QCloudUICKeyChainStoreProtocolTypeAppleTalk,
    QCloudUICKeyChainStoreProtocolTypeAFP,
    QCloudUICKeyChainStoreProtocolTypeTelnet,
    QCloudUICKeyChainStoreProtocolTypeSSH,
    QCloudUICKeyChainStoreProtocolTypeFTPS,
    QCloudUICKeyChainStoreProtocolTypeHTTPS,
    QCloudUICKeyChainStoreProtocolTypeHTTPProxy,
    QCloudUICKeyChainStoreProtocolTypeHTTPSProxy,
    QCloudUICKeyChainStoreProtocolTypeFTPProxy,
    QCloudUICKeyChainStoreProtocolTypeSMB,
    QCloudUICKeyChainStoreProtocolTypeRTSP,
    QCloudUICKeyChainStoreProtocolTypeRTSPProxy,
    QCloudUICKeyChainStoreProtocolTypeDAAP,
    QCloudUICKeyChainStoreProtocolTypeEPPC,
    QCloudUICKeyChainStoreProtocolTypeNNTPS,
    QCloudUICKeyChainStoreProtocolTypeLDAPS,
    QCloudUICKeyChainStoreProtocolTypeTelnetS,
    QCloudUICKeyChainStoreProtocolTypeIRCS,
    QCloudUICKeyChainStoreProtocolTypePOP3S,
};

typedef NS_ENUM(NSInteger, QCloudUICKeyChainStoreAuthenticationType) {
    QCloudUICKeyChainStoreAuthenticationTypeNTLM = 1,
    QCloudUICKeyChainStoreAuthenticationTypeMSN,
    QCloudUICKeyChainStoreAuthenticationTypeDPA,
    QCloudUICKeyChainStoreAuthenticationTypeRPA,
    QCloudUICKeyChainStoreAuthenticationTypeHTTPBasic,
    QCloudUICKeyChainStoreAuthenticationTypeHTTPDigest,
    QCloudUICKeyChainStoreAuthenticationTypeHTMLForm,
    QCloudUICKeyChainStoreAuthenticationTypeDefault,
};

typedef NS_ENUM(NSInteger, QCloudUICKeyChainStoreAccessibility) {
    QCloudUICKeyChainStoreAccessibilityWhenUnlocked = 1,
    QCloudUICKeyChainStoreAccessibilityAfterFirstUnlock,
    QCloudUICKeyChainStoreAccessibilityAlways,
    QCloudUICKeyChainStoreAccessibilityWhenPasscodeSetThisDeviceOnly
    __OSX_AVAILABLE_STARTING(__MAC_10_10, __IPHONE_8_0),
    QCloudUICKeyChainStoreAccessibilityWhenUnlockedThisDeviceOnly,
    QCloudUICKeyChainStoreAccessibilityAfterFirstUnlockThisDeviceOnly,
    QCloudUICKeyChainStoreAccessibilityAlwaysThisDeviceOnly,
}
__OSX_AVAILABLE_STARTING(__MAC_10_9, __IPHONE_4_0);

typedef NS_ENUM(NSInteger, UICKeyChainStoreAuthenticationPolicy) {
    UICKeyChainStoreAuthenticationPolicyUserPresence = kSecAccessControlUserPresence,
};

@interface QCloudUICKeyChainStore : NSObject

@property (nonatomic, readonly) QCloudUICKeyChainStoreItemClass itemClass;

@property (nonatomic, readonly, nullable) NSString *service;
@property (nonatomic, readonly, nullable) NSString *accessGroup;

@property (nonatomic, readonly, nullable) NSURL *server;
@property (nonatomic, readonly) QCloudUICKeyChainStoreProtocolType protocolType;
@property (nonatomic, readonly) QCloudUICKeyChainStoreAuthenticationType authenticationType;

@property (nonatomic) QCloudUICKeyChainStoreAccessibility accessibility;
@property (nonatomic, readonly) UICKeyChainStoreAuthenticationPolicy authenticationPolicy
__OSX_AVAILABLE_STARTING(__MAC_10_10, __IPHONE_8_0);

@property (nonatomic) BOOL synchronizable;

@property (nonatomic, nullable) NSString *authenticationPrompt
__OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_8_0);

@property (nonatomic, readonly, nullable) NSArray UIC_KEY_TYPE *allKeys;
@property (nonatomic, readonly, nullable) NSArray *allItems;

+ (NSString *)defaultService;
+ (void)setDefaultService:(NSString *)defaultService;

+ (QCloudUICKeyChainStore *)keyChainStore;
+ (QCloudUICKeyChainStore *)keyChainStoreWithService:(nullable NSString *)service;
+ (QCloudUICKeyChainStore *)keyChainStoreWithService:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup;

+ (QCloudUICKeyChainStore *)keyChainStoreWithServer:(NSURL *)server protocolType:(QCloudUICKeyChainStoreProtocolType)protocolType;
+ (QCloudUICKeyChainStore *)keyChainStoreWithServer:(NSURL *)server protocolType:(QCloudUICKeyChainStoreProtocolType)protocolType authenticationType:(QCloudUICKeyChainStoreAuthenticationType)authenticationType;

- (instancetype)init;
- (instancetype)initWithService:(nullable NSString *)service;
- (instancetype)initWithService:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup;

- (instancetype)initWithServer:(NSURL *)server protocolType:(QCloudUICKeyChainStoreProtocolType)protocolType;
- (instancetype)initWithServer:(NSURL *)server protocolType:(QCloudUICKeyChainStoreProtocolType)protocolType authenticationType:(QCloudUICKeyChainStoreAuthenticationType)authenticationType;

+ (nullable NSString *)stringForKey:(NSString *)key;
+ (nullable NSString *)stringForKey:(NSString *)key service:(nullable NSString *)service;
+ (nullable NSString *)stringForKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup;
+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key;
+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key service:(nullable NSString *)service;
+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup;

+ (nullable NSData *)dataForKey:(NSString *)key;
+ (nullable NSData *)dataForKey:(NSString *)key service:(nullable NSString *)service;
+ (nullable NSData *)dataForKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup;
+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key;
+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key service:(nullable NSString *)service;
+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup;

- (BOOL)contains:(nullable NSString *)key;

- (BOOL)setString:(nullable NSString *)string forKey:(nullable NSString *)key;
- (BOOL)setString:(nullable NSString *)string forKey:(nullable NSString *)key label:(nullable NSString *)label comment:(nullable NSString *)comment;
- (nullable NSString *)stringForKey:(NSString *)key;

- (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key;
- (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key label:(nullable NSString *)label comment:(nullable NSString *)comment;
- (nullable NSData *)dataForKey:(NSString *)key;

+ (BOOL)removeItemForKey:(NSString *)key;
+ (BOOL)removeItemForKey:(NSString *)key service:(nullable NSString *)service;
+ (BOOL)removeItemForKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup;

+ (BOOL)removeAllItems;
+ (BOOL)removeAllItemsForService:(nullable NSString *)service;
+ (BOOL)removeAllItemsForService:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup;

- (BOOL)removeItemForKey:(NSString *)key;

- (BOOL)removeAllItems;

- (nullable NSString *)objectForKeyedSubscript:(NSString<NSCopying> *)key;
- (void)setObject:(nullable NSString *)obj forKeyedSubscript:(NSString<NSCopying> *)key;

+ (nullable NSArray UIC_KEY_TYPE *)allKeysWithItemClass:(QCloudUICKeyChainStoreItemClass)itemClass;
- (nullable NSArray UIC_KEY_TYPE *)allKeys;

+ (nullable NSArray *)allItemsWithItemClass:(QCloudUICKeyChainStoreItemClass)itemClass;
- (nullable NSArray *)allItems;

- (void)setAccessibility:(QCloudUICKeyChainStoreAccessibility)accessibility authenticationPolicy:(UICKeyChainStoreAuthenticationPolicy)authenticationPolicy
__OSX_AVAILABLE_STARTING(__MAC_10_10, __IPHONE_8_0);

#if TARGET_OS_IOS
- (void)sharedPasswordWithCompletion:(nullable void (^)(NSString * __nullable account, NSString * __nullable password, NSError * __nullable error))completion;
- (void)sharedPasswordForAccount:(NSString *)account completion:(nullable void (^)(NSString * __nullable password, NSError * __nullable error))completion;

- (void)setSharedPassword:(nullable NSString *)password forAccount:(NSString *)account completion:(nullable void (^)(NSError * __nullable error))completion;
- (void)removeSharedPasswordForAccount:(NSString *)account completion:(nullable void (^)(NSError * __nullable error))completion;

+ (void)requestSharedWebCredentialWithCompletion:(nullable void (^)(NSArray UIC_CREDENTIAL_TYPE *credentials, NSError * __nullable error))completion;
+ (void)requestSharedWebCredentialForDomain:(nullable NSString *)domain account:(nullable NSString *)account completion:(nullable void (^)(NSArray UIC_CREDENTIAL_TYPE *credentials, NSError * __nullable error))completion;

+ (NSString *)generatePassword;
#endif

@end

@interface QCloudUICKeyChainStore (ErrorHandling)

+ (nullable NSString *)stringForKey:(NSString *)key error:(NSError * __nullable __autoreleasing * __nullable)error;
+ (nullable NSString *)stringForKey:(NSString *)key service:(nullable NSString *)service error:(NSError * __nullable __autoreleasing * __nullable)error;
+ (nullable NSString *)stringForKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup error:(NSError * __nullable __autoreleasing * __nullable)error;

+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key error:(NSError * __nullable __autoreleasing * __nullable)error;
+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key service:(nullable NSString *)service error:(NSError * __nullable __autoreleasing * __nullable)error;
+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup error:(NSError * __nullable __autoreleasing * __nullable)error;

+ (nullable NSData *)dataForKey:(NSString *)key error:(NSError * __nullable __autoreleasing * __nullable)error;
+ (nullable NSData *)dataForKey:(NSString *)key service:(nullable NSString *)service error:(NSError * __nullable __autoreleasing * __nullable)error;
+ (nullable NSData *)dataForKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup error:(NSError * __nullable __autoreleasing * __nullable)error;

+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key error:(NSError * __nullable __autoreleasing * __nullable)error;
+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key service:(nullable NSString *)service error:(NSError * __nullable __autoreleasing * __nullable)error;
+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup error:(NSError * __nullable __autoreleasing * __nullable)error;

- (BOOL)setString:(nullable NSString *)string forKey:(NSString * )key error:(NSError * __nullable __autoreleasing * __nullable)error;
- (BOOL)setString:(nullable NSString *)string forKey:(NSString * )key label:(nullable NSString *)label comment:(nullable NSString *)comment error:(NSError * __nullable __autoreleasing * __nullable)error;

- (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key error:(NSError * __nullable __autoreleasing * __nullable)error;
- (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key label:(nullable NSString *)label comment:(nullable NSString *)comment error:(NSError * __nullable __autoreleasing * __nullable)error;

- (nullable NSString *)stringForKey:(NSString *)key error:(NSError * __nullable __autoreleasing * __nullable)error;
- (nullable NSData *)dataForKey:(NSString *)key error:(NSError * __nullable __autoreleasing * __nullable)error;

+ (BOOL)removeItemForKey:(NSString *)key error:(NSError * __nullable __autoreleasing * __nullable)error;
+ (BOOL)removeItemForKey:(NSString *)key service:(nullable NSString *)service error:(NSError * __nullable __autoreleasing * __nullable)error;
+ (BOOL)removeItemForKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup error:(NSError * __nullable __autoreleasing * __nullable)error;

+ (BOOL)removeAllItemsWithError:(NSError * __nullable __autoreleasing * __nullable)error;
+ (BOOL)removeAllItemsForService:(nullable NSString *)service error:(NSError * __nullable __autoreleasing * __nullable)error;
+ (BOOL)removeAllItemsForService:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup error:(NSError * __nullable __autoreleasing * __nullable)error;

- (BOOL)removeItemForKey:(NSString *)key error:(NSError * __nullable __autoreleasing * __nullable)error;
- (BOOL)removeAllItemsWithError:(NSError * __nullable __autoreleasing * __nullable)error;

@end

@interface QCloudUICKeyChainStore (ForwardCompatibility)

+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key genericAttribute:(nullable id)genericAttribute;
+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key genericAttribute:(nullable id)genericAttribute error:(NSError * __nullable __autoreleasing * __nullable)error;

+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key service:(nullable NSString *)service genericAttribute:(nullable id)genericAttribute;
+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key service:(nullable NSString *)service genericAttribute:(nullable id)genericAttribute error:(NSError * __nullable __autoreleasing * __nullable)error;

+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup genericAttribute:(nullable id)genericAttribute;
+ (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup genericAttribute:(nullable id)genericAttribute error:(NSError * __nullable __autoreleasing * __nullable)error;

+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key genericAttribute:(nullable id)genericAttribute;
+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key genericAttribute:(nullable id)genericAttribute error:(NSError * __nullable __autoreleasing * __nullable)error;

+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key service:(nullable NSString *)service genericAttribute:(nullable id)genericAttribute;
+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key service:(nullable NSString *)service genericAttribute:(nullable id)genericAttribute error:(NSError * __nullable __autoreleasing * __nullable)error;

+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup genericAttribute:(nullable id)genericAttribute;
+ (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key service:(nullable NSString *)service accessGroup:(nullable NSString *)accessGroup genericAttribute:(nullable id)genericAttribute error:(NSError * __nullable __autoreleasing * __nullable)error;

- (BOOL)setString:(nullable NSString *)string forKey:(NSString *)key genericAttribute:(nullable id)genericAttribute;
- (BOOL)setString:(nullable NSString *)string forKey:(NSString *)key genericAttribute:(nullable id)genericAttribute error:(NSError * __nullable __autoreleasing * __nullable)error;

- (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key genericAttribute:(nullable id)genericAttribute;
- (BOOL)setData:(nullable NSData *)data forKey:(NSString *)key genericAttribute:(nullable id)genericAttribute error:(NSError * __nullable __autoreleasing * __nullable)error;

@end

@interface QCloudUICKeyChainStore (Deprecation)

- (void)synchronize __attribute__((deprecated("calling this method is no longer required")));
- (BOOL)synchronizeWithError:(NSError * __nullable __autoreleasing * __nullable)error __attribute__((deprecated("calling this method is no longer required")));

@end

NS_ASSUME_NONNULL_END
