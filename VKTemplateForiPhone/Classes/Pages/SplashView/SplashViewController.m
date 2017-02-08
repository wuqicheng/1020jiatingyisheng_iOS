//
//  SplashViewController.m
//  NanShaZhiChuang
//
//  Created by vescky.luo on 14-9-8.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()<UIScrollViewDelegate> {
    
}
@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initSplashView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSplashView {
    NSArray *arr = [[NSArray alloc] initWithObjects:@"splash1.jpg",@"splash2.jpg",@"splash3.jpg", nil];
    if (isBigScreen()) {
        arr = [[NSArray alloc] initWithObjects:@"splash1_ip5.jpg",@"splash2_ip5.jpg",@"splash3_ip5.jpg", nil];
    }
    
    //init scrollview
    [scView setContentSize:CGSizeMake(arr.count*scView.frame.size.width, scView.frame.size.height)];
    scView.pagingEnabled = YES;
    scView.showsHorizontalScrollIndicator = NO;
    scView.delegate = self;
    
    //init pagecontrol
    pageControl.currentPage = 0;
    pageControl.numberOfPages = arr.count;
    [pageControl addTarget:self action:@selector(getChangePage:) forControlEvents:UIControlEventValueChanged];
    pageControl.hidden = YES;
    
    for (int i = 0; i < arr.count; i++) {
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(i*scView.frame.size.width, 0, scView.frame.size.width, scView.frame.size.height)];
        [imgv setImage:[UIImage imageNamed:[arr objectAtIndex:i]]];
        [scView addSubview:imgv];
    }
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnDone setTitle:@"进入App" forState:UIControlStateNormal];
    btnDone.frame = CGRectMake(scView.contentSize.width - scView.frame.size.width, 0, scView.frame.size.width, scView.frame.size.height);
    [btnDone addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [scView addSubview:btnDone];
}

- (void)getChangePage:(UIPageControl *)_pageControl {
    int page = _pageControl.currentPage;
    CGRect frame = scView.frame;
    frame.origin.x = frame.size.width * page;//根据页数算要显示的第几页在scrollView的初始坐标
    frame.origin.y = 0;
    [scView scrollRectToVisible:frame animated:YES];//根据坐标显示第几页
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;//根据坐标算页数
    pageControl.currentPage = page;//页数赋值给pageControl的当前页
}

#pragma mark - button action
- (IBAction)btnAction:(UIButton*)sender {
    [self.view removeFromSuperview];
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    [usd setObject:@1 forKey:@"FLAG_OPENED"];
    [usd synchronize];
}

@end
