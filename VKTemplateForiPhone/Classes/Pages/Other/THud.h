//
//  THud.h
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/11/9.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THud : NSObject

+(THud *)sharedInstance;
-(void)disPlayMessage:(NSString *)message;
-(void)hideHud;
-(void)showtips:(NSString *)message;

@end
