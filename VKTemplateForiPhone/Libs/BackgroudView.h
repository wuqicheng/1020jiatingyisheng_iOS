//
//  ZYBackgroudView.h
//  6diandan
//
//  Created by chinalong on 15/4/3.
//  Copyright (c) 2015年 forgtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackgroudView : NSObject
+(BackgroudView*)shareInstance;
- (void)addView:(UIView*)view andToView:(UIView*)superView;
- (void)hide;
- (void)setCenter;
@end
