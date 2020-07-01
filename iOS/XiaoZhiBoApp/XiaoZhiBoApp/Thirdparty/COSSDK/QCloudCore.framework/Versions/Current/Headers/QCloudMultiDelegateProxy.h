//
//  QCloudMultiDelegateProxy.h
//  TACAuthorization
//
//  Created by Dong Zhao on 2017/12/11.
//

#import <Foundation/Foundation.h>


/**
 解决delegate多次转发的问题，通常情况下绝大部分SDK的delegate为一个属性，也就是说只能接受一个delegate，但是当SDK容纳了非常多的场景逻辑的时候，这个时候实现delegate协议的地方就非常臃肿难以拆分。所以设计了这个基础机制，可以将delegate向多个多想转发消息。这是一个1对多的转发代理。
 */
@interface QCloudMultiDelegateProxy<Type> : NSObject

/**
 添加一个接受转发的委托
 @note 在内部对该对象为弱应用，不用担心会产生内存问题。同时在编程的时候，也不要认为我们会持有该对象。
 @param delegate 接受转发的对象
 */
- (void) addDelegate:(Type)delegate;

/**
 删除一个接受转发的委托

 @param delegate 将要被删除的对象
 */
- (void) removeDelegate:(Type)delegate;
@end
