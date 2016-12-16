//
//  ETUserDefaults.m
//  MyProject
//
//  Created by Ethan on 16/8/10.
//  Copyright © 2016年 ethan. All rights reserved.
//

#import "ETUserDefaults.h"
#import "NSData+AES256.h"

static NSURL *__userDefaultsPath__;
static NSMutableDictionary *__defaults__;
static dispatch_queue_t __userDefaultsQueue__;
NSString * const AES256Key = @"xco23498zflkjglasf09vlaa0jl20kcx";

@interface ETUserDefaults ()

@end

@implementation ETUserDefaults

+ (ETUserDefaults *)standardUserDefaults {
    static ETUserDefaults *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ETUserDefaults new];
    });
    return instance;
}

+ (void)clearStandardUserDefaults {
    dispatch_barrier_sync([self _userDefaultsQueue], ^{
        [__defaults__ removeAllObjects];
        [[NSFileManager defaultManager] removeItemAtURL:[self _userDefaultsPath] error:nil];
    });
}

- (instancetype)init {
    if (self = [super init]) {
        [self synchronize];
    }
    return self;
}

- (id)objectForKey:(NSString *)defaultName {
    __block id object;
    dispatch_barrier_sync([self.class _userDefaultsQueue], ^{
        object = [[self.class _defaults] objectForKey:defaultName];
    });
    return object;
}

- (void)setObject:(id)value forKey:(NSString *)defaultName {
    dispatch_barrier_async([self.class _userDefaultsQueue], ^{
        if (value) {
            [[self.class _defaults] setObject:value forKey:defaultName];
        } else {
            [[self.class _defaults] removeObjectForKey:defaultName];
        }
        [self synchronize];
    });
}

- (void)removeObjectForKey:(NSString *)defaultName {
    dispatch_barrier_async([self.class _userDefaultsQueue], ^{
        [[self.class _defaults] removeObjectForKey:defaultName];
        [self synchronize];
    });
}

- (void)synchronize {
    dispatch_async([self.class _userDefaultsQueue], ^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self.class _defaults]];
        NSData *enData = [data AES256EncryptWithKey:AES256Key];
        [enData writeToURL:[self.class _userDefaultsPath] atomically:YES];
        [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: NSFileProtectionComplete} ofItemAtPath:[self.class _userDefaultsPath].relativePath error:nil];
    });
}

#pragma mark - private


+ (NSURL*)_userDefaultsPath {
    if (!__userDefaultsPath__) {
        __userDefaultsPath__ = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"defaults.data"]];
    }
    return __userDefaultsPath__;
}

+ (NSMutableDictionary*)_defaults {
    if (!__defaults__) {
        __defaults__ = [NSMutableDictionary new];
        NSData *enData = [NSData dataWithContentsOfURL:[self _userDefaultsPath]];
        NSData *data = [enData AES256DecryptWithKey:AES256Key];
        if (data) {
            NSMutableDictionary *localDefaults = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [__defaults__ addEntriesFromDictionary:localDefaults];
        }
        
        NSDictionary *systemUserDefaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
        if (__defaults__.count == 0 && systemUserDefaults.count != 0) {
            [__defaults__ addEntriesFromDictionary:systemUserDefaults];
            [systemUserDefaults.allKeys enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:obj];
            }];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return __defaults__;
}

+ (dispatch_queue_t)_userDefaultsQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __userDefaultsQueue__ = dispatch_queue_create("userdefaults.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return __userDefaultsQueue__;
}

@end
