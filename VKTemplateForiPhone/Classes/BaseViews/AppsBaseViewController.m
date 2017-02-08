//
//  AppsBaseViewController.m
//  GDPU_Bible
//
//  Created by Vescky on 13-5-31.
//  Copyright (c) 2013年 gdpuDeveloper. All rights reserved.
//

#import "AppsBaseViewController.h"
#import "MyAlertView.h"

@interface AppsBaseViewController ()<MyAlertViewDelegate,MJRefreshBaseViewDelegate> {
    MyAlertView *myAlert;
}

@end


@implementation AppsBaseViewController
@synthesize noDataView,viewForTextInput,textFieldForTextInput;
@synthesize isTextInputViewOn;

@synthesize dataSource;
@synthesize disableLoadMore,disableRefresh,isLastPage = _isLastPage;
@synthesize _header,_footer;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self customBackButton];
    if (!isBigScreen()) {
        CGRect selfRect = self.view.frame;
        selfRect.size.height = 480.f;
        self.view.frame = selfRect;
    }
    
    self.view.backgroundColor = GetColorWithRGB(240, 240, 240);
    
    //定义导航栏标题字体颜色
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,
//                          [UIColor clearColor],NSShadowAttributeName,
                          [UIFont systemFontOfSize:20],NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    
    //适配ios7
    if (ios7OrLater()) {
        [self.navigationController.navigationBar setTranslucent:NO];
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        [self.navigationController.navigationBar setBarTintColor:GetColorWithRGB(0, 230, 22)];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else {
        [self.navigationController.navigationBar setTintColor:GetColorWithRGB(0, 230, 22)];
        self.navigationController.navigationBar.clipsToBounds = YES;
    }
    
    //适配ios7以下的系统
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //init nodata-view
    noDataView = [[UILabel alloc] init];
    noDataView.text = @"暂无数据~";
    noDataView.textColor = [UIColor blackColor];
    noDataView.textAlignment = 1;
    noDataView.font = [UIFont systemFontOfSize:16.0];
    
    [self initRefreshView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

//自定义样式的返回键
- (void)customBackButton {
    //自定义背景图片
    UIImage* image= [UIImage imageNamed:@"back.png"];
    CGRect frame_1= CGRectMake(0, 0, 20, 44);
    UIView *cView = [[UIView alloc] initWithFrame:frame_1];
    
    //自定义按钮图片
    UIImageView *cImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 11, 20)];
    [cImgView setImage:image];
    [cView addSubview:cImgView];
    
    //覆盖一个大按钮在上面，利于用户点击
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame_1];
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [cView addSubview:backButton];
    
    //创建导航栏按钮UIBarButtonItem
    UIBarButtonItem* backItem= [[UIBarButtonItem alloc] initWithCustomView:cView];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

//自定义样式的导航栏item-- 用图片
- (void)customNavigationBarItemWithImageName:(NSString*)imgName isLeft:(bool)isLeft {
    
    UIImage *btnImage = [UIImage imageNamed:imgName];
    //定制自己的风格的  UIBarButtonItem
    UIButton* jumpButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];//
    [jumpButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    
    if (isLeft) {
        [jumpButton addTarget:self action:@selector(leftBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* actionItem= [[UIBarButtonItem alloc] initWithCustomView:jumpButton];
        [self.navigationItem setLeftBarButtonItem:actionItem];
    }
    else {
        [jumpButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* actionItem= [[UIBarButtonItem alloc] initWithCustomView:jumpButton];
        [self.navigationItem setRightBarButtonItem:actionItem];
    }
    
}

//自定义样式的导航栏item -- 用标题
- (void)customNavigationBarItemWithTitleName:(NSString*)titleName isLeft:(bool)isLeft {
    if (titleName && titleName.length > 0) {
        UIButton* jumpButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40+((titleName.length-2)*10), 40)];//微调
        [jumpButton setTitle:titleName forState:UIControlStateNormal];
        [jumpButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [jumpButton.titleLabel setTextAlignment:2];
        
        if (isLeft) {
            [jumpButton addTarget:self action:@selector(leftBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem* actionItem= [[UIBarButtonItem alloc] initWithCustomView:jumpButton];
            [self.navigationItem setLeftBarButtonItem:actionItem];
        }
        else {
            [jumpButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem* actionItem= [[UIBarButtonItem alloc] initWithCustomView:jumpButton];
            [self.navigationItem setRightBarButtonItem:actionItem];
        }
        
    }
}

//返回键响应函数，重写此函数，实现返回前执行一系列操作
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

//导航栏左键响应函数，重写此函数，响应点击事件；此函数与上面的goback区分
- (void)leftBarButtonAction {
    NSLog(@"need to implement this methor");
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    NSLog(@"need to implement this methor");
}

- (void)showLoginStyleIfNotLogged {
    UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    lView.backgroundColor = self.view.backgroundColor;
    
//    UIButton 
}

#pragma mark - Button Action
- (void)jumpToLoginPage {
    
}

#pragma mark - Responding to keyboard events
//键盘即将出现时的回调函数
- (void)keyboardWillShow:(NSNotification *)notification {
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect.size.height = keyboardRect.size.height <= 0? 216.0f+32.0f : keyboardRect.size.height;
    NSLog(@"%@",NSStringFromCGRect(keyboardRect));
    float animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationDuration animations:^{
        setViewFrameOriginY(viewForTextInput, self.view.frame.size.height - keyboardRect.size.height - viewForTextInput.frame.size.height);
        isTextInputViewOn = YES;
    }];
    
}
//键盘即将隐藏时的回调函数
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    float animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationDuration animations:^{
        setViewFrameOriginY(viewForTextInput, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [viewForTextInput removeFromSuperview];
        isTextInputViewOn = NO;
    }];
}

- (void)autoRecycleDismissKeyborad {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)didBecomeActive {
    [self performSelector:@selector(adjustNavigationBar) withObject:nil afterDelay:1.0];
}

- (void)adjustNavigationBar {
    CGRect nRect = self.navigationController.navigationBar.frame;
    nRect.origin.y = 20.0f;
    self.navigationController.navigationBar.frame = nRect;
}

#pragma mark - 快速获取一些值
- (float)viewOriginX {
    return self.view.frame.origin.x;
}
- (float)viewOriginY {
    return self.view.frame.origin.y;
}
- (float)viewHeight {
    return self.view.frame.size.height;
}
- (float)viewWidth {
    return self.view.frame.size.width;
}

#pragma mark - hud view
//- (void)showWithStatus:(NSString *)status {
//    [statusView showWithStatus:status];
//}
//
//- (void)showWithStatusWithTimeInterval:(NSString *)status timeInterval:(NSTimeInterval)timeInterval {
//    [statusView showWithStatus:status dismissDelay:timeInterval];
//}
//
//- (void)dismissStatusView {
//    [statusView dismiss];
//}

#pragma mark - other
- (void)showNoData:(bool)showOn {
    if (showOn) {
        noDataView.frame = CGRectMake(0, 100.0f, self.view.frame.size.width, 200.0f);
        noDataView.numberOfLines = 0;
        noDataView.textAlignment = NSTextAlignmentCenter;
        if (![noDataView isDescendantOfView:self.view]) {
            [self.view addSubview:noDataView];
        }
        [self.view bringSubviewToFront:noDataView];
    }
    else {
        [noDataView removeFromSuperview];
    }
}

- (void)showNoDataWithTips:(NSString*)tipString {
    [self showNoData:YES];
    noDataView.text = tipString;
}

- (void)nodataViewShowFrame:(CGRect)frame {
    noDataView.frame = frame;
}

- (void)showTextInputViewWithTag:(int)tTag defaultText:(NSString*)defaultText placeHolder:(NSString*)placeHolderText {
    if (!viewForTextInput) {
        //init input-view
        viewForTextInput = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 48.0f, self.view.frame.size.width, 48.0f)];
        viewForTextInput.backgroundColor = [UIColor clearColor];
        
        UIImageView *imgvBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewForTextInput.frame.size.width, viewForTextInput.frame.size.height)];
        [imgvBg setImage:[UIImage imageNamed:@"textfield_big_bg.png"]];
        [viewForTextInput addSubview:imgvBg];
        
        textFieldForTextInput = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 9.0f, viewForTextInput.frame.size.width - 2 * 10.0, viewForTextInput.frame.size.height - 2 * 9.0f)];
        textFieldForTextInput.background = [UIImage imageNamed:@"textfield_bg.png"];
        textFieldForTextInput.delegate = self;
        textFieldForTextInput.returnKeyType = UIReturnKeyDone;
        [viewForTextInput addSubview:textFieldForTextInput];
    }
    if (isValidString(defaultText)) {
        textFieldForTextInput.text = defaultText;
    }
    if (isValidString(placeHolderText)) {
        textFieldForTextInput.placeholder = placeHolderText;
    }
//    [textFieldForTextInput setReturnKeyType:UIReturnKeyDone];
    textFieldForTextInput.tag = tTag;
    [self.view addSubview:viewForTextInput];
    [textFieldForTextInput becomeFirstResponder];
    
}

- (void)showAlertWithTitle:(NSString*)alertTitle message:(NSString*)alertMessage cancelButton:(NSString*)cancelButton sureButton:(NSString*)sureButton {
    if (!isValidString(alertTitle)) {
        alertTitle = @"提示";
    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:cancelButton otherButtonTitles:sureButton, nil];
//    [alert show];
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    if (isValidString(cancelButton)) {
        [buttons addObject:cancelButton];
    }
    if (isValidString(sureButton)) {
        [buttons addObject:sureButton];
    }
    
    myAlert = [[MyAlertView alloc] initWithTitle:alertTitle alertContent:alertMessage defaultStyleWithButtons:buttons];
    myAlert.delegate = self;
    [myAlert show];
}

- (void)showAlertWithTitle:(NSString*)alertTitle message:(NSString*)alertMessage cancelButton:(NSString*)cancelButton sureButton:(NSString*)sureButton tag:(int)aTag {
    if (!isValidString(alertTitle)) {
        alertTitle = @"提示";
    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:cancelButton otherButtonTitles:sureButton, nil];
//    alert.tag = aTag;
//    [alert show];
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    if (isValidString(cancelButton)) {
        [buttons addObject:cancelButton];
    }
    if (isValidString(sureButton)) {
        [buttons addObject:sureButton];
    }
    
    myAlert = [[MyAlertView alloc] initWithTitle:alertTitle alertContent:alertMessage defaultStyleWithButtons:buttons];
    myAlert.tag = aTag;
    myAlert.delegate = self;
    [myAlert show];
}

- (void)autoRecycleKeyboardBind:(UIView*)v {
    
}

#pragma mark - UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)setIsLastPage:(bool)isLastPage {
    _isLastPage = isLastPage;
    if (!disableLoadMore) {
        _footer.isLastPage = isLastPage;
    }
}

- (void)initRefreshView {
    if (!disableLoadMore) {
        _footer = [MJRefreshFooterView footer];
//        _footer.scrollView = self.tableview;
        _footer.delegate = self;
        
    }
    if (!disableRefresh) {
        _header = [MJRefreshHeaderView header];
//        _header.scrollView = tbView;
        _header.delegate = self;
    }
}

- (void)stopRefreshing{
    [_header endRefreshing];
    [_footer endRefreshing];
}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView {
    if (refreshView == _header) {
        //刷新
        [self refreshData];
    }
    else {
        //加载更多
        [self loadMoreData];
    }
}

//need to over write
- (void)refreshData {
    
}

//need to over write
- (void)loadMoreData  {
    
}





@end
