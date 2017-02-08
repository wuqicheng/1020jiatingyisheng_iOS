
//本地缓存图片

#import <Foundation/Foundation.h>

@interface CacheImage : NSObject

/***************************************** 获取图片类型  *****************************************/

-(NSString *)imageType:(NSString *)str;


/***************************************** 创建缓存文件夹  *****************************************/

-(BOOL) createDirInCache:(NSString *)dirName;


/***************************************** 删除图片缓存  *****************************************/

- (BOOL) deleteDirInCache:(NSString *)dirName;


/***************************************** 缓存目录  ********************************************/

-(NSString* )pathInCacheDirectory:(NSString *)fileName;


/***************************************** 获取缓存图片(1)  *****************************************/

- (NSData*) loadImageData:(NSString *)directoryPath urlStr:(NSString *)urlStr;


/***************************************** 获取缓存图片(2)  *****************************************/

-(NSData*) loadImageData:(NSString *)directoryPath imageName:( NSString *)imageName;


/*****************************************  图片本地缓存 *****************************************/

- (BOOL) saveImageToCacheDir:(NSString *)directoryPath  image:(UIImage *)image imageName:(NSString *)imageName imageType:(NSString *)imageType;


@end
