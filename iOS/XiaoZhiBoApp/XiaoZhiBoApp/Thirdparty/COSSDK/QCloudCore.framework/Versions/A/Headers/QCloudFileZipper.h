//
//  QCloudFileZipper.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/15.
//
//

#import <Foundation/Foundation.h>

@interface QCloudFileZipper : NSObject
- (instancetype) initWithInputFilePath:(NSString*)path;
- (BOOL) outputToPath:(NSString*)path;
@end
