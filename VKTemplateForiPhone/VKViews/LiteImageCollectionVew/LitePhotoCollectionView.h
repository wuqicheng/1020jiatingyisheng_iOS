//
//  LitePhotoCollectionView.h
//  GolfFriend
//
//  Created by Vescky on 13-12-4.
//  Copyright (c) 2013年 vescky.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LitePhotoCollectionViewDelegate <NSObject>

- (void)imageDidTapped:(int)index;

- (void)imageDidTapped:(int)index identifyString:(NSString*)idString;

@end

@interface LitePhotoCollectionView : UIViewController {
    
}

@property (nonatomic,strong) NSMutableArray *photoCollection;//web image url string
@property (nonatomic,strong) NSMutableArray *coverCollection;//覆盖物
@property (nonatomic,strong) NSString *identifyString;//标记
@property (nonatomic,strong) UIColor *bgColor;
@property (nonatomic,assign) id <LitePhotoCollectionViewDelegate> delegate;
@property float margin,viewWidth,scaleHDW;// -- scaleHDW:height/width的比例
@property int colCount;
@property bool onlyResponsToDelegateMenthod;
@property bool marginToBounce;//内容到边界的距离

- (void)refreshView;

- (float)getViewHeight;

@end
