//
//  SearchTextField.h
//  UGift
//
//  Created by xuzeyu on 15/8/13.
//  Copyright (c) 2015年 Joe.x. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^BlockBtnClick)(NSInteger);
@interface SearchTextField : UITextField
@property (nonatomic , strong) BlockBtnClick blockBtnClick;
@end
