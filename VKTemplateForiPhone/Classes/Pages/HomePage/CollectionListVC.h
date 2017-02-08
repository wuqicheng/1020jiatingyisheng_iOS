//
//  CollectionListVC.h
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/9/1.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionListVC : AppsBaseViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MJRefreshBaseViewDelegate,UICollectionViewDelegate>{
    
}
@property (strong, nonatomic)UICollectionView *collectionView;
@property (nonatomic,assign) NSInteger tag;
@property (nonatomic, strong) NSDictionary *dic; //title

@property (nonatomic,assign) bool disableRefresh,disableLoadMore;
@property (nonatomic,assign) bool isLastPage;
@property (nonatomic,strong) MJRefreshHeaderView *_header;
@property (nonatomic,strong) MJRefreshFooterView *_footer;

@end
