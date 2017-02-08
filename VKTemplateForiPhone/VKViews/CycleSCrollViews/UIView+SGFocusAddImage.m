

#import "UIView+SGFocusAddImage.h"
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"

@implementation UIView (SGFocusAddImage)

- (void)cycleScrollView:(SGFocusImageFrame *)targetView imageURLStr:(NSArray *)imageURLStrArr image:(NSArray *)imageArr imageID:(NSArray *)imageID title:(NSArray *)titile
{
    int length = 0;
    
    BOOL hasCacheImage = NO;
    
    NSString *keyStr = nil;
    
    NSArray *tempArr = nil;
    
    if(imageArr)
    {
        length = (int)imageArr.count;
        tempArr = imageArr;
        keyStr = @"image";
    }
    else if(imageURLStrArr)
    {
        length = (int)imageURLStrArr.count;
        tempArr = imageURLStrArr;
        keyStr = @"imageURLStr";
    }
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0 ; i < length; i++)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [titile objectAtIndex:i],@"title" ,
                              [tempArr objectAtIndex:i],keyStr,
                              [imageID objectAtIndex:i],@"imageID",
                              nil];
        [tempArray addObject:dict];
    }
    
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
    //添加最后一张图 用于循环
    if (length > 1)
    {
        NSDictionary *dict = [tempArray objectAtIndex:length-1];
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithDict:dict tag:-1];
        [itemArray addObject:item];
    }
    for (int i = 0; i < length; i++)
    {
        NSDictionary *dict = [tempArray objectAtIndex:i];
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithDict:dict tag:i];
        [itemArray addObject:item];
        
    }
    //添加第一张图 用于循环
    if (length >1)
    {
        NSDictionary *dict = [tempArray objectAtIndex:0];
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithDict:dict tag:length];
        [itemArray addObject:item];
    }
    
    if(imageArr)
    {
        hasCacheImage = YES;
    }
    
    [targetView changeImageViewsContent:itemArray cache:hasCacheImage];

}

@end
