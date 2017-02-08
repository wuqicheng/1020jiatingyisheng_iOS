/*
 @overview: 本地缓存
 */

#import <Foundation/Foundation.h>

#define APIRequestCache @"APIRequestCache.dat"

@interface Cache : NSObject

/*
 @overview: 归档
 */

+ (void)save:(id)target key:(NSString *)key;

/*
 @overview: 反归档
 */

+ (id)readByKey:(NSString *)key;

@end

