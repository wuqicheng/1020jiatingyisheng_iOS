//
//  SingleChatViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "SingleChatViewController.h"
#import "MessageManager.h"
#import "ChatCell.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "EvaluateDoctorViewController.h"
#import "UserSessionCenter.h"

@interface SingleChatViewController ()<ChatCellDelegate,MJPhotoBrowserDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    float toolBarHeightNormal,keyboardHeight;
    NSString *peerUserNickName,*peerUserAvatar,*peerUserId;
    NSString *selfUserNickName,*selfUserAvatar,*selfUserId;
    NSInteger messagePosition;//现在的消息位置 tableViewPosition
    bool isJumpped/*是否去了评价页*/,isPushed/*push了一个vc？*/;
}

@end

@implementation SingleChatViewController

- (void)viewDidLoad {
    self.disableLoadMore = YES;
//    self.disableRefresh = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self customBackButton];
    
    ratingView1.userInteractionEnabled = NO;
    ratingView2.userInteractionEnabled = NO;
    
    tvContent.layer.borderWidth = 1.f;
    tvContent.layer.borderColor = GetColorWithRGB(228, 228, 228).CGColor;
    tvContent.layer.cornerRadius = 1.f;
    tvContent.contentSize = tvContent.frame.size;
    
    tbView.clipsToBounds = NO;
    toolBarHeightNormal = tvContent.frame.size.height+2*6.f;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:NotificationDidRecieveNewChatMessage object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeybord)];
    [tbView addGestureRecognizer:tap];
    
    dataSource = [[NSMutableArray alloc] init];
    messagePosition = 0;
    [self loadConversation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isPushed) {
        //刷新数据
        messagePosition = 0;
        [self loadConversation];
    }
    isPushed = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self._header.stringPulling = @"下拉加载更多记录";
    self._header.stringRelease = @"松开查看更多记录";
     self._header.stringRefreshing = @"加载中...";
    [self._header setState:RefreshStatePulling];
    [self._header setState:RefreshStateNormal];
    
    [self performSelector:@selector(adjustTableView) withObject:nil afterDelay:0.1f];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationDidRecieveNewChatMessage object:nil];
}

#pragma mark - Views Operator
///用数据初始化界面
- (void)initView {
    self.title = peerUserNickName;
    if (self.isConversationOver) {
        //对话已结束
        toolBar.hidden = YES;
        if (self.isCommented) {
            //已评论，显示评价板，隐藏评论按钮
            [self customNavigationBarItemWithImageName:nil isLeft:NO];
            evaluateBar.hidden = NO;
            
            labelEvaluate.text = [self.conversationInfo objectForKey:@"comment_msg"];
            ratingView1.rating = [[self.conversationInfo objectForKey:@"attitude_star"] integerValue];
            ratingView2.rating = [[self.conversationInfo objectForKey:@"ability_star"] integerValue];
        }
        else {
            if (!self.isThirdMan) {
                //未评论,显示评价按钮
                [self customNavigationBarItemWithTitleName:@"评价" isLeft:NO];
                
                if (!isJumpped) {
                    [self showAlertWithTitle:nil message:[NSString stringWithFormat:@"您还没评价%@",peerUserNickName] cancelButton:@"我知道了" sureButton:nil tag:101];
                }
                isJumpped = YES;
            }
            else {
                //其他人
                self.title = peerUserNickName;
                evaluateBar.hidden = NO;
            }
        }
    }
    
    [self adjustTableView];
}

///设置工具栏展开和收起
- (void)setToolbarStatus:(bool)expanded {
    if (expanded) {
        [UIView animateWithDuration:0.5 animations:^{
            setViewFrameOriginY(toolBar, self.view.frame.size.height-toolBar.frame.size.height);
        } completion:^(BOOL finished) {
            [self adjustTableView];
        }];
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            setViewFrameOriginY(toolBar, self.view.frame.size.height-toolBarHeightNormal);
        } completion:^(BOOL finished) {
            [self adjustTableView];
        }];
    }
}

///调整tableview的高度
- (void)adjustTableView {
    float margin = 5.f;
    if (!self.isConversationOver) {
        //正常对话
        setViewFrameSizeHeight(tbView, toolBar.frame.origin.y - margin);
    }
    else {
        //已结束
        if (self.isCommented) {
            //已评价
            setViewFrameSizeHeight(tbView, evaluateBar.frame.origin.y - margin);
        }
        else {
            //未评价
            setViewFrameSizeHeight(tbView, self.view.frame.size.height - margin);
        }
    }
    
    [tbView reloadData];
    
    NSLog(@"tb-height:%f",tbView.frame.size.height);
    [self performSelector:@selector(tableViewScrollToBottom) withObject:nil afterDelay:0.1f];
}

///列表滚动到最底部
- (void)tableViewScrollToBottom {
    if (tbView.contentSize.height > tbView.frame.size.height) {
        CGPoint offset = CGPointMake(0, tbView.contentSize.height - tbView.frame.size.height);
        [tbView setContentOffset:offset animated:YES];
    }
}

///回收键盘
- (void)dismissKeybord {
    [tvContent resignFirstResponder];
}

///用数据去更新tableview
- (void)updateTableViewWithRecords:(NSArray*)records isNewMessages:(bool)isNewMessages {
    if (!isValidArray(records)) {
        return;
    }
    NSInteger currentCount = dataSource.count;
    [self updateRecords:records];
    
    [tbView reloadData];
    [tbView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataSource.count-currentCount-1 inSection:0] atScrollPosition:isNewMessages?UITableViewScrollPositionBottom:UITableViewScrollPositionTop animated:isNewMessages];
}


#pragma mark - 自动高度的TextView实现
- (void)fitTextViewHeight:(UITextView*)textView {
    float rowHeight = 20.f,textViewOriginHeight = 38.f;
    NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:textView.font,NSFontAttributeName, nil];
    CGSize textSize = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width-10.f, 70.f) options:NSStringDrawingUsesLineFragmentOrigin  attributes:attribute context:nil].size;
    //NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
    textSize.height = (int)(textSize.height / rowHeight + 1) * rowHeight;
    
    if (textSize.height <= textViewOriginHeight) {
        setViewFrameSizeHeight(textView, textViewOriginHeight);
        setViewFrameSizeHeight(toolBar, 146.f);
        setViewFrameOriginY(toolBar, self.view.frame.size.height-toolBarHeightNormal-keyboardHeight);
        [textView setContentOffset:CGPointMake(0, 0.f) animated:NO];
    }
    else {
        if (textView.frame.size.height != textSize.height) {
            float gap = textSize.height - textView.frame.size.height;
            setViewFrameSizeHeight(textView, textSize.height);
            setViewFrameSizeHeight(toolBar, toolBar.frame.size.height+gap);
            setViewFrameOriginY(toolBar, toolBar.frame.origin.y-gap);
            
            [textView setContentOffset:CGPointMake(0, textView.contentSize.height - textView.frame.size.height) animated:NO];
        }
    }
}


#pragma mark - over-write
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    btnMore.selected = NO;
    
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        setViewFrameOriginY(toolBar, self.view.frame.size.height-keyboardRect.size.height-toolBarHeightNormal);
    } completion:^(BOOL finished) {
        [self adjustTableView];
    }];
}

//键盘即将隐藏时的回调函数
- (void)keyboardWillHide:(NSNotification *)aNotification {
    keyboardHeight = 0;
    [UIView animateWithDuration:0.3 animations:^{
        setViewFrameOriginY(toolBar, self.view.frame.size.height-toolBarHeightNormal);
    } completion:^(BOOL finished) {
        [self adjustTableView];
    }];
}

- (void)rightBarButtonAction {
    //评价
    if (self.isConversationOver) {
        //结束后才能评价
        EvaluateDoctorViewController *eVc = [[EvaluateDoctorViewController alloc] init];
        eVc.conversationId = self.conversationId;
        [self.navigationController pushViewController:eVc animated:YES];
        isPushed = YES;
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"结束后才能评价哦"];
    }
}

#pragma mark - Request
///发送消息
- (void)sendMessage:(MessageModel*)msg {
    if (msg.messageContent.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"不能发送空消息"];
        return;
    }
    
    msg.conversationId = self.conversationId;
    msg.isSelfSender = YES;
    msg.senderId = selfUserId;
    msg.senderNickName = selfUserNickName;
    msg.senderAvatar = selfUserAvatar;
    msg.recieverId = peerUserId;
    msg.time = getStringFromDate(@"yyyy-MM-dd HH:mm:ss", [NSDate date]);
    [dataSource addObject:msg];
//    [tbView reloadData];
    [self adjustTableView];
    
    if (!isValidString(msg.conversationId) || !isValidString(msg.senderId) || !isValidString(msg.recieverId) || !isValidString(msg.messageContent) || !msg.messageType) {
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:msg.conversationId forKey:@"conversation_id"];
    [params setObject:@(msg.messageType) forKey:@"content_type"];
    [params setObject:msg.senderId forKey:@"from_user_id"];
    [params setObject:msg.recieverId forKey:@"to_user_id"];
    [params setObject:msg.messageContent forKey:@"msg_content"];
    
    NSLog(@"qqq%@",params);
    
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"sendMessageForChart.action" param:params onCompletion:^(id jsonResponse) {
        
        
        NSLog(@"wwww%@",jsonResponse);
        if ([[NSString stringWithFormat:@"%@",[jsonResponse objectForKey:@"status"]] integerValue] == 1) {
            NSLog(@"发送消息成功:%@",msg.messageContent);
        }
        else if ([[NSString stringWithFormat:@"%@",[jsonResponse objectForKey:@"status"]] integerValue] == -111) {
            NSLog(@"会话已结束");
            [self showAlertWithTitle:nil message:[NSString stringWithFormat:@"此次咨询会话已结束，您还没评价%@",peerUserNickName] cancelButton:@"我知道了" sureButton:nil tag:101];
        }
        else {
            NSLog(@"发送消息失败:%@\ndesc:%@",msg.messageContent,[jsonResponse objectForKey:@"desc"]);
        }
    } onError:^(NSError *error) {
        NSLog(@"发送消息，网络连接超时!");
    } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
}

///获取最新的消息
- (void)loadNewestMessages {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   self.conversationId,@"conversation_id",
                                   selfUserId,@"user_id",nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getCurConversationAllNoReadChartMsgList.action" param:params onCompletion:^(id jsonResponse) {
        NSArray *arr = [self parseData:[jsonResponse objectForKey:@"rows"]];
        if (isValidArray(arr)) {
            [self updateTableViewWithRecords:arr isNewMessages:YES];
            [self adjustTableView];
        }
    } onError:^(NSError *error) {
        
    } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
}


///获取整个会话的内容，包括会话的属性和聊天消息
- (void)loadConversation {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.conversationId,@"conversation_id",@(messagePosition),@"divisionid", nil];//,@(8),@"pagesize"  每页条数，默认50
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getCurConversationAllChartMsgList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self stopRefreshing];
        
        self.conversationInfo = [jsonResponse objectForKey:@"infos"];
        
        if (messagePosition <= 0) {//init
            //Public
            self.conversationId = [self.conversationInfo objectForKey:@"conversation_id"];
            self.isConversationOver = [[self.conversationInfo objectForKey:@"chart_status"] boolValue];
            self.isCommented = isValidString([self.conversationInfo objectForKey:@"comment_msg"]);
            
            //己方
            selfUserId = [self.conversationInfo objectForKey:@"cs_user_id"];
            selfUserNickName = [self.conversationInfo objectForKey:@"c_user_nick"];
            selfUserAvatar = [self.conversationInfo objectForKey:@"c_photo"];
            
            //对方
            peerUserAvatar = [self.conversationInfo objectForKey:@"d_photo"];
            peerUserNickName = [self.conversationInfo objectForKey:@"d_user_name"];
            peerUserId = [self.conversationInfo objectForKey:@"doctor_user_id"];
            
            NSString *currentUserId = [[UserSessionCenter shareSession] getUserId];
            if (![selfUserId isEqualToString:currentUserId] && ![peerUserId isEqualToString:currentUserId]) {
                //第三方人员，不能看图片
                self.isThirdMan = YES;
            }
            //第一次获取到消息
            NSArray *arr = [self parseData:[self.conversationInfo objectForKey:@"msg_list"]];
            if (isValidArray(arr)) {
                [dataSource addObjectsFromArray:arr];
                [self sortMessages];
//                [tbView reloadData];
            }
            
            [self initView];
        }
        else {
            //加载更多
            NSArray *arr = [self parseData:[self.conversationInfo objectForKey:@"msg_list"]];
            if (isValidArray(arr)) {
                [self updateTableViewWithRecords:arr isNewMessages:NO];//更新聊天列表
            }
        }
        
    } onError:^(NSError *error) {
        [self stopRefreshing];
        [SVProgressHUD dismiss];
    } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
}

#pragma mark - Data Operator
///处理推送信息
- (void)notificationHandler:(NSNotification*)aNotification {
    NSLog(@"%@",aNotification.object);
    [self loadNewestMessages];
}

///此处的作用相反，refresh是加载更多
- (void)refreshData {
    MessageModel *md = [dataSource firstObject];
    messagePosition = [md.messageId integerValue];
    [self loadConversation];
}

///解析message
- (NSArray*)parseData:(NSArray*)arr {
    MessageModel *lastMsg = nil;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (int i = 0; i < arr.count; i++) {
        MessageModel *md = [[MessageModel alloc] initWithJsonValue:[arr objectAtIndex:i]];
        if (self.isThirdMan && md.messageType == messageBodyType_Image) {
            //第三方人员，不能看图片
            continue;
        }
        //判断是否要显示时间
        if (lastMsg) {
            NSDate *dCurrent = getDateFromString(@"yyyy-MM-dd HH:mm:ss", md.time);
            NSDate *dPre = getDateFromString(@"yyyy-MM-dd HH:mm:ss", lastMsg.time);//[getDateFromString(@"yyyy-MM-dd HH:mm:ss", lastMsg.time) dateByAddingTimeInterval:3*60];
            NSLog(@"%f",[dCurrent timeIntervalSinceDate:dPre]);
            if (fabs([dCurrent timeIntervalSinceDate:dPre]) > 3*60) {//[[dCurrent laterDate:dPre] isEqualToDate:dPre]
                //超过3分钟，current显示时间
                md.showsTime = YES;
            }
            else {
                md.showsTime = NO;
            }
        }
        else {
            md.showsTime = YES;
        }
        lastMsg = md;
        
        [results addObject:md];
    }
    return results;
}

///更新数组，有的跳过，没有的加入
- (void)updateRecords:(NSArray*)records {
    NSMutableArray *newRecords = [[NSMutableArray alloc] init];
    for (int i = 0; i < records.count; i++) {
        MessageModel *md = [records objectAtIndex:i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId == %@", md.messageId];//message_id
        NSArray *result = [dataSource filteredArrayUsingPredicate:predicate];
        if (!isValidArray(result)) {
            //不存在，为新的
            [newRecords addObject:md];
        }
    }
    
    [dataSource addObjectsFromArray:newRecords];
    [self sortMessages];
}

///排序数组
- (void)sortMessages {
    //按照时间升序排列
    NSComparator cmptr = ^(MessageModel *obj1, MessageModel *obj2){
        NSDate *date1 = getDateFromString(@"yyyy-MM-dd HH:mm:ss", obj1.time);
        NSDate *date2 = getDateFromString(@"yyyy-MM-dd HH:mm:ss", obj2.time);
        NSDate *laterDate = [date1 laterDate:date2];
        if ([date1 isEqualToDate:laterDate]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        else if ([date2 isEqualToDate:laterDate]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *sortedArr = [dataSource sortedArrayUsingComparator:cmptr];
    dataSource = [[NSMutableArray alloc] initWithArray:sortedArr];
}

///获取数组中最早的id
- (NSString*)getLatestId {
    MessageModel *msg = [dataSource firstObject];
    NSInteger msgId = [msg.messageId integerValue];
    msgId++;
    return [NSString stringWithFormat:@"%@",@(msgId)];
}

#pragma mark - Button Action
///工具栏相应
- (IBAction)toolBarAction:(UIButton*)sender {
    if (sender.tag == 200) {
        //更多
        [tvContent resignFirstResponder];
        sender.selected = !sender.selected;
        [self setToolbarStatus:sender.selected];
    }
    else if (sender.tag == 201) {
        //发送
        MessageModel *md = [[MessageModel alloc] init];
        md.messageType = messageBodyType_Text;
        md.messageContent = tvContent.text;
        //send msg
        [self sendMessage:md];
        
        //clean up
        tvContent.text = @"";
        [self fitTextViewHeight:tvContent];
    }
    else if (sender.tag == 202) {
        //相册
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;  //是否可编辑
        //摄像头
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{
            NSLog(@"get picture");
        }];
    }
    else if (sender.tag == 203) {
        //拍摄
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController * picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            picker.allowsEditing = YES;  //是否可编辑
            //摄像头
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:^{
                NSLog(@"get picture");
            }];
        }else{
            //如果没有提示用户
            [SVProgressHUD showErrorWithStatus:String_Device_Not_Supported_Camera];
        }
    }
    
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reusedIdentify = @"ChatCell";
    ChatCell *cell = (ChatCell*)[tableView dequeueReusableCellWithIdentifier:reusedIdentify];
    if (!cell) {
        cell = (ChatCell*)[[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = [UIColor clearColor];
    cell.tag = indexPath.row;
    
    MessageModel *md = (MessageModel*)[dataSource objectAtIndex:indexPath.row];
//    if (indexPath.row < 1) {
//        md.showsTime = YES;
//    }
//    else {
//        MessageModel *mdPre = (MessageModel*)[dataSource objectAtIndex:indexPath.row-1];
//        NSDate *dCurrent = getDateFromString(@"yyyy-MM-dd HH:mm:ss", md.time);
//        NSDate *dPre = [getDateFromString(@"yyyy-MM-dd HH:mm:ss", mdPre.time) dateByAddingTimeInterval:3*60];
//        if ([[dCurrent laterDate:dPre] isEqualToDate:dCurrent]) {
//            //超过3分钟，current显示时间
//            md.showsTime = YES;
//        }
//        else {
//            md.showsTime = NO;
//        }
//    }
    if ([md.senderId isEqualToString:selfUserId]) {
        md.isSelfSender = YES;
        md.senderNickName = selfUserNickName;
        md.senderAvatar = selfUserAvatar;
    }
    else {
        md.isSelfSender = NO;
        md.senderNickName = peerUserNickName;
        md.senderAvatar = peerUserAvatar;
    }
    [cell setCellDataInfo:md];
    cell.delegate = self;
    
//    if ([indexPath row] == [((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]) row]) {
//        [self performSelector:@selector(tableViewScrollToFitPosition) withObject:nil afterDelay:0.1f];
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ChatCell getCellHeightWithDataInfo:[dataSource objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self fitTextViewHeight:textView];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        //跳到评价页
        [self rightBarButtonAction];
    }
}


#pragma mark - ChatCellDelegate
///聊天图片被点击
- (void)chatCell:(ChatCell*)chatCell contentImageDidClick:(UIImageView*)imgv {
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:1];
    MJPhoto *photo = [[MJPhoto alloc] init];
    photo.srcImageView = imgv; // 来源于哪个UIImageView
    photo.image = imgv.image;
    [photos addObject:photo];
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    browser.delegate = self;
    [browser show];
}

#pragma mark - UINavigationControllerDelegate,UIImagePickerControllerDelegate
//拍摄完成后要执行的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //得到图片
    __block UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *savePath = saveAndResizeImage(image, [NSString stringWithFormat:@"tmp_image_%@.png",getStringFromDate(@"yyyyMMddHHmmss", [NSDate date])],640);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"正在上传图片..."];
            [[AppsNetWorkEngine shareEngine] uploadImagePath:savePath onCompletion:^(id jsonResponse) {
                [SVProgressHUD dismiss];
                if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
                    [SVProgressHUD showSuccessWithStatus:@"上传成功!"];
                    MessageModel *md = [[MessageModel alloc] init];
                    md.messageType = messageBodyType_Image;
                    md.messageContent = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"message"];
                    md.attach = image;
                    [self sendMessage:md];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"上传失败，请重试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                }
            } onError:^(NSError *error) {
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"上传失败，请重试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }];
        });
        
    });
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"back to chat vc.");
        [tbView reloadData];
    }];
}

//点击Cancel按钮后执行方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"back to chat vc.");
    }];
}


@end
