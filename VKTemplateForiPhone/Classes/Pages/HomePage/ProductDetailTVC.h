//
//  ProductDetailTVC.h
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/9/6.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailTVC : UITableViewController

@property (nonatomic,strong) NSDictionary *detailInfo;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) NSMutableDictionary *heightDic;
@end
