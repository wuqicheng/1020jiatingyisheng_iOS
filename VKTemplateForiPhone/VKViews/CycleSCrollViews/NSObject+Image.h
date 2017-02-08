
//关于图片的一些设置

#import <Foundation/Foundation.h>

@interface NSObject (Image)

//将图片截取成圆形的图片
-(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset;

//图片的缩放
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
