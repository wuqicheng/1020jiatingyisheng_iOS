//
//  MySliderView.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "MySliderView.h"
#define kMargin 10.f

@implementation MySliderView
@synthesize currentPercentage = _currentPercentage,delegate;

- (instancetype)initWithFrame:(CGRect)frame cursorImage:(UIImage*)cImg foregroundImage:(UIImage*)fImg backgroundImage:(UIImage*)bImg {
    self = [self initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupViewWithSize:frame.size cursorImage:cImg foregroundImage:fImg backgroundImage:bImg];
    }
    return self;
}

- (void)setupViewWithSize:(CGSize)vSize cursorImage:(UIImage*)cImg foregroundImage:(UIImage*)fImg backgroundImage:(UIImage*)bImg {
    imgvBackground = [[UIImageView alloc] initWithFrame:CGRectMake(kMargin, (vSize.height-bImg.size.height)/2.f, vSize.width-2*kMargin, bImg.size.height)];
    [imgvBackground setImage:bImg];
//    imgvBackground.contentMode = UIViewContentModeCenter;
    [self addSubview:imgvBackground];
    
    imgvForeground = [[UIImageView alloc] initWithFrame:imgvBackground.frame];
    setViewFrameSizeWidth(imgvForeground, 0.F);
    imgvForeground.layer.cornerRadius = imgvForeground.frame.size.height / 2.F;
    [imgvForeground setImage:fImg];
//    imgvForeground.contentMode = UIViewContentModeCenter;
    imgvForeground.clipsToBounds = YES;
    [self addSubview:imgvForeground];
    
    btnCursor = [[UIButton alloc] initWithFrame:CGRectMake(imgvBackground.frame.origin.x, (vSize.height-cImg.size.height)/2.f, cImg.size.width, cImg.size.height)];
    [btnCursor setImage:cImg forState:UIControlStateNormal];
    [btnCursor addTarget:self action:@selector(wasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [btnCursor addTarget:self action:@selector(dragExit:withEvent:) forControlEvents:UIControlEventTouchUpInside |
     UIControlEventTouchUpOutside];
    [self addSubview:btnCursor];
}

- (void)setCurrentPercentage:(CGFloat)currentPercentage {
    if (currentPercentage > 1) {
        currentPercentage = 1;
    }
    _currentPercentage = currentPercentage;
    
    CGFloat fLength = imgvBackground.frame.size.width * currentPercentage;
    setViewFrameSizeWidth(imgvForeground, fLength);
    
    setViewFrameOriginX(btnCursor, imgvForeground.frame.origin.y+fLength);
}

- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event {
    // get the touch
    UITouch *touch = [[event touchesForView:button] anyObject];
    
    // get delta
    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
//    CGFloat delta_y = location.y - previousLocation.y;//y值不改变
    
    CGFloat minX = imgvBackground.frame.origin.x;
    CGFloat maxX = imgvBackground.frame.origin.x + imgvBackground.frame.size.width;
    //判断有无过界
    if (button.center.x + delta_x >= minX && button.center.x + delta_x <= maxX) {
        // move button
        button.center = CGPointMake(button.center.x + delta_x, button.center.y);//y值不改变 + delta_y
        
        _currentPercentage = imgvForeground.frame.size.width/imgvBackground.frame.size.width;
        //改变前景宽度
        setViewFrameSizeWidth(imgvForeground, button.center.x - imgvBackground.frame.origin.x);
        
//        NSLog(@"%f",_currentPercentage);
        if ([delegate respondsToSelector:@selector(mySliderView:valueDidChange:)]) {
            [delegate mySliderView:self valueDidChange:_currentPercentage];
        }
    }
    
}

- (void)dragExit:(UIButton*)button withEvent:(UIEvent *)event {
    if ([delegate respondsToSelector:@selector(mySliderViewDidFinishDragging:)]) {
        [delegate mySliderViewDidFinishDragging:self];
    }
}




@end
