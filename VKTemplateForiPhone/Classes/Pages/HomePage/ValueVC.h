//
//  ValueVC.h
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/8/30.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ValueVC;
@protocol meDelegate <NSObject>

-(void)delegateClick0:(NSString *)meStr;
@end

@interface ValueVC : UIViewController

@property (nonatomic,assign)NSInteger pageNoForView;
@property (nonatomic,assign)NSInteger pageNoForServer;

- (instancetype)initWithIndex:(NSInteger)index title:(NSString *)title;
@property(strong, nonatomic)id<meDelegate>delegate;

@end
