//
//  KeyBoard.h
//  WeiZaZhi
//
//  Created by ADUU on 15/12/10.
//  Copyright © 2015年 aduu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define KeyBoard [KeyBoardObserver shareInstance]
typedef void(^KeyBoardBlock)(CGFloat keyboardHeight);

/**
 使用完毕，需要调用removeObserver进行释放
 单例创建和释放分别需要写在viewWillAppear和viewDidDisappear内
 */
@interface KeyBoardObserver : NSObject

+ (id)shareInstance;
- (void)removeObserver;

- (void)keyboardWillShow:(KeyBoardBlock)block;
- (void)keyboardDidShow:(KeyBoardBlock)block;
- (void)keyboardWillHide:(KeyBoardBlock)block;
- (void)keyboardDidHide:(KeyBoardBlock)block;

@end
