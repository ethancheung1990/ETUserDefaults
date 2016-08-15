//
//  NSData+AES256.h
//  MyProject
//
//  Created by Ethan on 16/8/10.
//  Copyright © 2016年 ethan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)

-(NSData *)AES256EncryptWithKey:(NSString *)key;
-(NSData *)AES256DecryptWithKey:(NSString *)key;

@end
