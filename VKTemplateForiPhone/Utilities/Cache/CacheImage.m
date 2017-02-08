

#import "CacheImage.h"

@implementation CacheImage

- (id)init
{
    if(self = [super init])
    {
        
    }
    
    return self;
}

#pragma mark --- 缓存目录 ---

-(NSString* )pathInCacheDirectory:(NSString *)fileName
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    return [cachePath stringByAppendingPathComponent:fileName];
}

#pragma mark --- 创建缓存文件夹 ---

-(BOOL) createDirInCache:(NSString *)dirName
{
    
    NSString *imageDir = [self pathInCacheDirectory:dirName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir];
    BOOL isCreated = NO;
    if ( !existed == YES )
    {
        isCreated = [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed)
    {
        isCreated = YES;
        
    }
    return isCreated;
    
}

#pragma mark --- 删除图片缓存 ---

- (BOOL) deleteDirInCache:(NSString *)dirName
{
    NSString *imageDir = [self pathInCacheDirectory:dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    bool isDeleted = false;
    if ( isDir == YES && existed == YES )
    {
        isDeleted = [fileManager removeItemAtPath:imageDir error:nil];
    }
    
    return isDeleted;
}

#pragma mark --- 获取图片类型 ---

- (NSString *)imageType:(NSString *)str
{
    //默认为空
    NSString * imageTypeStr = @"";
    //从url中获取图片类型
    NSMutableArray *arr = (NSMutableArray *)[str componentsSeparatedByString:@"."];
    if (arr) {
        imageTypeStr = [arr objectAtIndex:arr.count-1];
    }
    return imageTypeStr;
}

#pragma mark --- 图片本地缓存 ---

- (BOOL) saveImageToCacheDir:(NSString *)directoryPath  image:(UIImage *)image imageName:(NSString *)imageName imageType:(NSString *)imageType
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:directoryPath];
    bool isSaved = false;
    if (  existed == YES )
    {
        if ([[imageType lowercaseString] isEqualToString:@"png"])
        {
            isSaved = [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
            
        }
        else if ([[imageType lowercaseString] isEqualToString:@"jpg"] || [[imageType lowercaseString] isEqualToString:@"jpeg"])
        {
            isSaved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
        }
        else
        {
            NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", imageType);
        }
    }
    return isSaved;
}

#pragma mark --- 获取缓存图片 ---

- (NSData*) loadImageData:(NSString *)directoryPath imageName:(NSString *)imageName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirExisted = [fileManager fileExistsAtPath:directoryPath];
    if (dirExisted == YES )
    {
        NSString *imagePath = [directoryPath stringByAppendingPathComponent:imageName];
        BOOL fileExisted = [fileManager fileExistsAtPath:imagePath];
        if (!fileExisted)
        {
            return NULL;
        }
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        return imageData;
        
    }
    else
    {
        return NULL;
    }
}

#pragma mark --- 获取缓存图片 ---

- (NSData*) loadImageData:(NSString *)directoryPath urlStr:(NSString *)urlStr
{
    NSString *imageName = [NSString stringWithFormat:@"%@.%@",[[NSURL URLWithString:urlStr] lastPathComponent],[self imageType:urlStr]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirExisted = [fileManager fileExistsAtPath:directoryPath];
    if (dirExisted == YES )
    {
        NSString *imagePath = [directoryPath stringByAppendingPathComponent:imageName];
        BOOL fileExisted = [fileManager fileExistsAtPath:imagePath];
        if (!fileExisted)
        {
            return NULL;
        }
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        return imageData;
        
    }
    else
    {
        return NULL;
    }

}





@end
