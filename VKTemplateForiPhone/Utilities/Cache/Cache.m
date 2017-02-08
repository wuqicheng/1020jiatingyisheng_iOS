
#import "Cache.h"
#import "NSObject+JsonHandler.h"
#import "NSString+JsonHandler.h"

@implementation Cache

+ (NSString *)getPath:(NSString *)str;
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                  , NSUserDomainMask
                                                                  , YES) objectAtIndex:0];
    NSString *infoPath = [documentPath stringByAppendingPathComponent:str];
    
    return infoPath;
    
}

+ (void)save:(id)target key:(NSString *)key
{
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    if (target) {
        NSString *jsonString;
        @try {
            jsonString = [target toJsonString];
        }
        @catch (NSException *exception) {
            jsonString = target;
        }
        @finally {
            [usd setObject:jsonString forKey:key];
        }
    }
    else {
        [usd removeObjectForKey:key];
    }
    
    [usd synchronize];
}

+ (id)readByKey:(NSString *)key
{
//    反归档
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    NSString *jsonString = [usd objectForKey:key];
    return [jsonString toJsonValue];
}

@end
