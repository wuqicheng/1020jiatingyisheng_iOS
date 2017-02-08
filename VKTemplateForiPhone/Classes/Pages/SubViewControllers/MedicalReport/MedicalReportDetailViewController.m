//
//  MedicalReportDetailViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "MedicalReportDetailViewController.h"
#import "LitePhotoCollectionView.h"

@interface MedicalReportDetailViewController () {
    LitePhotoCollectionView *photosView;
}

@end

@implementation MedicalReportDetailViewController
@synthesize detailInfo,isReport;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (isReport) {
        self.title = @"病历详情";
    }
    else {
//        [self.navigationController.navigationBar addSubview:titleView];
//        titleView.center = CGPointMake(self.view.frame.size.width/2.f, self.navigationController.navigationBar.frame.size.height/2.f);
        self.title = @"健康活动记录";
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self customBackButton];
    [self initView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [titleView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView {
    labelTitle.text = isReport ? [detailInfo objectForKey:@"record_title"] : [detailInfo objectForKey:@"active_theme"];
    labelTime.text = getShortDateTimeForShow([detailInfo objectForKey:@"create_date"]);
    
    float margin = 5.f;
    NSArray *imgs = [[detailInfo objectForKey:@"record_images"] componentsSeparatedByString:@","];
    imgs = [self filterImgs:imgs];
    if (isValidArray(imgs)) {
        photosView = [[LitePhotoCollectionView alloc] init];
        [photosView setPhotoCollection:[[NSMutableArray alloc] initWithArray:imgs]];
        [photosView setMargin: margin];
        [photosView setViewWidth:scView.frame.size.width - 2 * margin];
        [photosView setColCount:3];
        [photosView.view setFrame:CGRectMake(margin,
                                             wView.frame.origin.y + wView.frame.size.height + 2 * margin,
                                             scView.frame.size.width - 2 * margin,
                                             [photosView getViewHeight])];
        [scView addSubview:photosView.view];
    }
    
    [wView loadHTMLString:OptimizeHtmlString((isReport ? [detailInfo objectForKey:@"record_content"] : [detailInfo objectForKey:@"active_desc"])) baseURL:nil];
    wView.scrollView.scrollEnabled = NO;
    
}

- (NSArray*)filterImgs:(NSArray*)arr {
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < arr.count; i++) {
        NSString *str = [arr objectAtIndex:i];
        if (isValidString(str)) {
            [resultArr addObject:str];
        }
    }
    return resultArr;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    setViewFrameSizeHeight(webView, webView.scrollView.contentSize.height);
    setViewFrameOriginY(photosView.view, webView.frame.origin.y+webView.frame.size.height+20.f);
    scView.contentSize = CGSizeMake(scView.frame.size.width, photosView.view.frame.origin.y+photosView.view.frame.size.height);
}



@end
