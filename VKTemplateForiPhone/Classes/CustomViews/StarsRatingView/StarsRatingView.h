//
//  StarsRatingView.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/12.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseView.h"

@interface StarsRatingView : AppsBaseView {
    NSMutableArray *stars;
}

@property (nonatomic,assign,getter=getRating) NSInteger rating;

@end
