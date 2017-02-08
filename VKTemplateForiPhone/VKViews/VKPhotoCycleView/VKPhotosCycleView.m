//
//  VKPhotosCycleView.m
//  test
//
//  Created by vescky.luo on 14-9-9.
//  Copyright (c) 2014年 vescky.luo. All rights reserved.
//

#import "VKPhotosCycleView.h"
#import "UIImageView+WebCache.h"

#define Label_Height 30.0f
#define Label_Font [UIFont systemFontOfSize:15.0]
#define Label_Color [UIColor whiteColor]

#define PageControl_Alignment 1 //0左边，1中间，2右边
#define PageControl_Dot_Width 15.0f
#define PageControl_Dot_Height 24.0f

#define Play_Interval 3.0

#define Max_Index 100000

@interface VKPhotosCycleView() {
    int currentIndex;
}
@end

@implementation VKPhotosCycleView
@synthesize dataSource,delegate;
@synthesize labelTitle,tbView,pageControl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame data:(NSMutableArray*)data target:(id)target buttomMaskColor:(UIColor*)mColor {
    self = [self initWithFrame:frame];
    if (self) {
        dataSource = data;
        delegate = target;
        int factor = (Max_Index / 2) % dataSource.count;
        currentIndex = factor == 0 ? Max_Index / 2 : Max_Index / 2 - factor;//找出最接近中点的0页
        NSLog(@"%d",currentIndex);
        
        //init tableview
        tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.width)];
        tbView.transform = CGAffineTransformMakeRotation(-M_PI / 2);//table横向
        tbView.frame = CGRectMake(0, 0, tbView.frame.size.width, tbView.frame.size.height);
        tbView.dataSource = self;
        tbView.delegate = self;
        tbView.pagingEnabled = YES;
        tbView.showsVerticalScrollIndicator = NO;
        tbView.showsHorizontalScrollIndicator = NO;
        tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tbView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(currentIndex<dataSource.count? currentIndex : 0) inSection:0]
                      atScrollPosition:UITableViewScrollPositionNone
                              animated:NO];
        [self addSubview:tbView];
        
//        //init buttom mask
        if (mColor && ![mColor isEqual:[UIColor clearColor]]) {
            UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - PageControl_Dot_Height, frame.size.width, PageControl_Dot_Height)];
            maskView.backgroundColor = mColor;
            maskView.alpha = 0.6;
            [self addSubview:maskView];
        }
        
        
        //init label
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                               frame.size.height - Label_Height + 3.0f,
                                                               frame.size.width - dataSource.count * PageControl_Dot_Width,
                                                               Label_Height)];
        labelTitle.textColor = Label_Color;
        labelTitle.font = Label_Font;
        [self addSubview:labelTitle];
        
        //init pagecontrol
        float pageControlX = 0;
        if (PageControl_Alignment == 1) {
            //center
            pageControlX = (frame.size.width - (dataSource.count * PageControl_Dot_Width)) / 2.0;
        }
        if (PageControl_Alignment == 2) {
            //right
            pageControlX = labelTitle.frame.size.width;
        }
        pageControl = [[UIPageControl alloc] init];
        pageControl.frame = CGRectMake(pageControlX,
                                       frame.size.height - PageControl_Dot_Height ,
                                       dataSource.count * PageControl_Dot_Width,
                                       PageControl_Dot_Height);
        pageControl.numberOfPages = dataSource.count;
        pageControl.currentPage = 0;
        [self addSubview:pageControl];
        [self showTitle];
        
        [tbView reloadData];
        [self performSelector:@selector(autoPlay) withObject:nil afterDelay:Play_Interval];
    }
    return self;
}

- (void)setData:(NSMutableArray*)data target:(id)target buttomMaskColor:(UIColor*)mColor {
    if (!isValidArray(data)) {
        return;
    }
    dataSource = data;
    delegate = target;
    int factor = (Max_Index / 2) % dataSource.count;
    currentIndex = factor == 0 ? Max_Index / 2 : Max_Index / 2 - factor;//找出最接近中点的0页
    NSLog(@"%d",currentIndex);
    
    //init tableview
    tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.width)];
    tbView.transform = CGAffineTransformMakeRotation(-M_PI / 2);//table横向
    tbView.frame = CGRectMake(0, 0, tbView.frame.size.width, tbView.frame.size.height);
    tbView.dataSource = self;
    tbView.delegate = self;
    tbView.pagingEnabled = YES;
    tbView.showsVerticalScrollIndicator = NO;
    tbView.showsHorizontalScrollIndicator = NO;
    tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tbView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(currentIndex<Max_Index? currentIndex : 0) inSection:0]
                  atScrollPosition:UITableViewScrollPositionNone
                          animated:NO];
    [self addSubview:tbView];
    
    //init mask
    if (mColor && ![mColor isEqual:[UIColor clearColor]]) {
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - PageControl_Dot_Height, self.frame.size.width, PageControl_Dot_Height)];
        maskView.backgroundColor = mColor;
        maskView.alpha = 0.2;
        [self addSubview:maskView];
    }
    
    
    //init label
    labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                           self.frame.size.height - Label_Height + 3.0f,
                                                           self.frame.size.width - dataSource.count * PageControl_Dot_Width,
                                                           Label_Height)];
    labelTitle.textColor = Label_Color;
    labelTitle.font = Label_Font;
    [self addSubview:labelTitle];
    
    //init pagecontrol
    float pageControlX = 0;
    if (PageControl_Alignment == 1) {
        //center
        pageControlX = (self.frame.size.width - (dataSource.count * PageControl_Dot_Width)) / 2.0;
    }
    if (PageControl_Alignment == 2) {
        //right
        pageControlX = labelTitle.frame.size.width;
    }
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(pageControlX,
                                   self.frame.size.height - PageControl_Dot_Height ,
                                   dataSource.count * PageControl_Dot_Width,
                                   PageControl_Dot_Height);
    pageControl.numberOfPages = dataSource.count;
    pageControl.currentPage = 0;
    [self addSubview:pageControl];
    [self showTitle];
    
    [tbView reloadData];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoPlay) object:nil];
    [self performSelector:@selector(autoPlay) withObject:nil afterDelay:Play_Interval];
}

- (void)autoPlay {
    if (dataSource && dataSource.count > 1) {
        [self next];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoPlay) object:nil];
        [self performSelector:@selector(autoPlay) withObject:nil afterDelay:Play_Interval];
    }
}

- (void)next {
    currentIndex++;
    [tbView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(currentIndex<Max_Index? currentIndex : 0) inSection:0]
                  atScrollPosition:UITableViewScrollPositionNone
                          animated:YES];
    pageControl.currentPage = currentIndex % dataSource.count;
    [self showTitle];
}

- (void)adjustPageNumber {
    int page = (tbView.contentOffset.y+self.frame.size.width/2.0) / self.frame.size.width;
//    NSLog(@"-- %f --",tbView.contentOffset.y);
    if (page != currentIndex) {
        currentIndex = page;
        [self showTitle];
    }
    pageControl.currentPage = currentIndex % dataSource.count;
}

- (void)showTitle {
    VKPhotosCycleViewItem *item = [dataSource objectAtIndex:(currentIndex % dataSource.count)];
    labelTitle.text = item.title;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //停止自动播放
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoPlay) object:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self adjustPageNumber];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"scrollViewWillEndDragging");
    //等待动画结束，再检测content offset
//    [self performSelector:@selector(adjustPageNumber) withObject:nil afterDelay:0.f];
    //开始自动播放
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoPlay) object:nil];
    [self performSelector:@selector(autoPlay) withObject:nil afterDelay:Play_Interval];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!dataSource) {
        return 0;
    }
    if (dataSource.count == 1) {
        pageControl.hidden = YES;
        return 1;
    }
    return Max_Index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentify = @"VKPhotosCycleView";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.width)];
    }
    UIImageView *imgvTmp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    imgvTmp.contentMode = UIViewContentModeScaleAspectFill;
    VKPhotosCycleViewItem *item = [dataSource objectAtIndex:(indexPath.row % dataSource.count)];
    
    UIImage *img = [UIImage imageNamed:item.imageUrl];
    if (img) {
        //bundle image
        [imgvTmp setImage:img];
    }
    else {
        //network image
        [imgvTmp setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:Defualt_Loading_Image];
    }
    
    [cell.contentView addSubview:imgvTmp];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size.width;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentIndex = indexPath.row;
    if ([delegate respondsToSelector:@selector(photosCycleView:didSelectedItem:)]) {
        [delegate photosCycleView:self didSelectedItem:[dataSource objectAtIndex:(indexPath.row % dataSource.count)]];
    }
}

@end
