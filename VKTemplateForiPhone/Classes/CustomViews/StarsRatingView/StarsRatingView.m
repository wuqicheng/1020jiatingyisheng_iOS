//
//  StarsRatingView.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/12.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "StarsRatingView.h"

#define ImageStarFull [UIImage imageNamed:@"star-on.png"]
#define ImageStarEmpty [UIImage imageNamed:@"star-off.png"]
#define ButtonBaseTag 100

@implementation StarsRatingView
@synthesize rating = _rating;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // 初始化代码
        [self setupView:self.frame];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView:frame];
    }
    return self;
}

#pragma mark - Init
- (void)setupView:(CGRect)frame  {
    stars = [[NSMutableArray alloc] init];
    CGFloat w = frame.size.width / 5.f;
    CGFloat h = frame.size.height;
    for (int i = 0; i < 5; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*w, 0.f, w, h)];
        [btn setImage:ImageStarEmpty forState:UIControlStateNormal];
        [btn setImage:ImageStarFull forState:UIControlStateSelected];
        btn.tag = ButtonBaseTag + i;
        [btn addTarget:self action:@selector(starDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}

#pragma mark - Private
- (NSInteger)getRatedScore {
    for (NSInteger i = 4; i >= 0; i--) {
        UIButton *btn = (UIButton*)[self viewWithTag:ButtonBaseTag+i];
        if (btn.selected) {
            return i+1;
        }
    }
    return 0;
}

#pragma mark - Public
- (void)setRating:(NSInteger)rating {
    _rating = rating;
    UIButton *btn = (UIButton*)[self viewWithTag:ButtonBaseTag+rating-1];
    if (btn) {
        [self starDidClick:btn];
    }
}

- (NSInteger)getRating {
    return [self getRatedScore];
}

#pragma mark - events
- (IBAction)starDidClick:(UIButton*)sender {
    //重置所有
    [self resetAllStarts];
    
    NSInteger sIndex = sender.tag % 10;
    
    for (NSInteger i = 0; i <= sIndex; i++) {
        UIButton *btn = (UIButton*)[self viewWithTag:ButtonBaseTag+i];
        btn.selected = YES;
    }
}

- (void)resetAllStarts {
    for (NSInteger i = 0; i < 5; i++) {
        UIButton *btn = (UIButton*)[self viewWithTag:ButtonBaseTag+i];
        btn.selected = NO;
    }
}

@end
