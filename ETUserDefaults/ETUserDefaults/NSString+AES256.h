//
//  NSString+AES256.h
//  MyProject
//
//  Created by Ethan on 16/8/10.
//  Copyright © 2016年 ethan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AES256)

-(NSString *)AES256EncryptWithKey:(NSString *)key;
-(NSString *)AES256DecryptWithKey:(NSString *)key;

@end
