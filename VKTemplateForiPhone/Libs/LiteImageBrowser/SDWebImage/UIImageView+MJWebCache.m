//
//  UIImageView+MJWebCache.m
//  FingerNews
//
//  Created by mj on 13-10-2.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "UIImageView+MJWebCache.h"

@implementation UIImageView (MJWebCache)
- (void)setImageURL:(NSURL *)url placeholder:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageLowPriority];
}

- (void)setImageURLStr:(NSString *)urlStr placeholder:(UIImage *)placeholder
{
    if (!urlStr || ![urlStr isKindOfClass:NSClassFromString(@"NSString")]) {
        return;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *localFilePath = [getCachePath() stringByAppendingPathComponent:[urlStr lastPathComponent]];
    if ([fm fileExistsAtPath:localFilePath]) {
        UIImage *img = [UIImage imageWithContentsOfFile:localFilePath];
        if (img) {
            [self setImage:img];
            return;
        }
    }
    [self setImageURL:[NSURL URLWithString:urlStr] placeholder:(placeholder ? placeholder : Defualt_Loading_Image)];
}
@end
