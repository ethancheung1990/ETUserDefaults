//
//  ETUserDefaults.h
//  MyProject
//
//  Created by Ethan on 16/8/10.
//  Copyright © 2016年 ethan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETUserDefaults : NSObject

+ (instancetype)standardUserDefaults;

/**
 * 清空
 */
+ (void)clearStandardUserDefaults;

- (id)objectForKey:(NSString *)defaultName;

- (void)setObject:(id)value forKey:(NSString *)defaultName;

- (void)removeObjectForKey:(NSString *)defaultName;

/**
 * 同步，一般情况不需要手动调用
 */
- (void)synchronize;

@end
