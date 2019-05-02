//
//  QCloudXMLDictionary.h
//
//  Version 1.4.1
//
//  Created by Nick Lockwood on 15/11/2010.
//  Copyright 2010 Charcoal Design. All rights reserved.
//
//  Get the latest version of QCloudXMLDictionary from here:
//
//  https://github.com/nicklockwood/QCloudXMLDictionary
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"


NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, QCloudXMLDictionaryAttributesMode)
{
    QCloudXMLDictionaryAttributesModePrefixed = 0, //default
    QCloudXMLDictionaryAttributesModeDictionary,
    QCloudXMLDictionaryAttributesModeUnprefixed,
    QCloudXMLDictionaryAttributesModeDiscard
};


typedef NS_ENUM(NSInteger, QCloudXMLDictionaryNodeNameMode)
{
    QCloudXMLDictionaryNodeNameModeRootOnly = 0, //default
    QCloudXMLDictionaryNodeNameModeAlways,
    QCloudXMLDictionaryNodeNameModeNever
};


static NSString *const QCloudXMLDictionaryAttributesKey   = @"__attributes";
static NSString *const QCloudXMLDictionaryCommentsKey     = @"__comments";
static NSString *const QCloudXMLDictionaryTextKey         = @"__text";
static NSString *const QCloudXMLDictionaryNodeNameKey     = @"__name";
static NSString *const QCloudXMLDictionaryAttributePrefix = @"_";


@interface QCloudXMLDictionaryParser : NSObject <NSCopying>

+ (QCloudXMLDictionaryParser *)sharedInstance;

@property (nonatomic, assign) BOOL collapseTextNodes; // defaults to YES
@property (nonatomic, assign) BOOL stripEmptyNodes;   // defaults to YES
@property (nonatomic, assign) BOOL trimWhiteSpace;    // defaults to YES
@property (nonatomic, assign) BOOL alwaysUseArrays;   // defaults to NO
@property (nonatomic, assign) BOOL preserveComments;  // defaults to NO
@property (nonatomic, assign) BOOL wrapRootNode;      // defaults to NO

@property (nonatomic, assign) QCloudXMLDictionaryAttributesMode attributesMode;
@property (nonatomic, assign) QCloudXMLDictionaryNodeNameMode nodeNameMode;

- (nullable NSDictionary<NSString *, id> *)dictionaryWithParser:(NSXMLParser *)parser;
- (nullable NSDictionary<NSString *, id> *)dictionaryWithData:(NSData *)data;
- (nullable NSDictionary<NSString *, id> *)dictionaryWithString:(NSString *)string;
- (nullable NSDictionary<NSString *, id> *)dictionaryWithFile:(NSString *)path;

@end


@interface NSDictionary (QCloudXMLDictionary)

+ (nullable NSDictionary<NSString *, id> *)qcxml_dictionaryWithXMLParser:(NSXMLParser *)parser;
+ (nullable NSDictionary<NSString *, id> *)qcxml_dictionaryWithXMLData:(NSData *)data;
+ (nullable NSDictionary<NSString *, id> *)qcxml_dictionaryWithXMLString:(NSString *)string;
+ (nullable NSDictionary<NSString *, id> *)qcxml_dictionaryWithXMLFile:(NSString *)path;

@property (nonatomic, readonly, copy, nullable) NSDictionary<NSString *, NSString *> *qcxml_attributes;
@property (nonatomic, readonly, copy, nullable) NSDictionary<NSString *, id> *qcxml_childNodes;
@property (nonatomic, readonly, copy, nullable) NSArray<NSString *> *qcxml_comments;
@property (nonatomic, readonly, copy, nullable) NSString *qcxml_nodeName;
@property (nonatomic, readonly, copy, nullable) NSString *qcxml_innerText;
@property (nonatomic, readonly, copy) NSString *qcxml_innerXML;
@property (nonatomic, readonly, copy) NSString *qcxml_XMLString;

- (nullable NSArray *)qcxml_arrayValueForKeyPath:(NSString *)keyPath;
- (nullable NSString *)qcxml_stringValueForKeyPath:(NSString *)keyPath;
- (nullable NSDictionary<NSString *, id> *)qcxml_dictionaryValueForKeyPath:(NSString *)keyPath;

@end


@interface NSString (QCloudXMLDictionary)

@property (nonatomic, readonly, copy) NSString *QCXMLEncodedString;

@end


NS_ASSUME_NONNULL_END


#pragma GCC diagnostic pop
