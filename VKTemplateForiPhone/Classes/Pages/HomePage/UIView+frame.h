//
//  UIView+frame.h
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/8/29.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (frame)

- (CGFloat)originX;
- (CGFloat)originY;
- (CGPoint)origin;
- (CGFloat)width;
- (CGFloat)height;
- (CGSize)size;

- (void)setOriginX:(CGFloat)x;
- (void)setOriginY:(CGFloat)y;
- (void)setOrigin:(CGPoint)origin;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)setSize:(CGSize)size;

@end
