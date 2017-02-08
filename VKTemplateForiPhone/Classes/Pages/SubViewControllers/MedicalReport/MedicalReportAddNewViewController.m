//
//  MedicalReportAddNewViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "MedicalReportAddNewViewController.h"
#import "MedicalReportPhotoCell.h"
#import "MyActionSheetView.h"
#import "UserSessionCenter.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#define CollectionView_Col_Number 3
#define CollectionView_Row_Number 3

@interface MedicalReportAddNewViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,MyActionSheetViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,MedicalReportPhotoCellDelegate,MJPhotoBrowserDelegate> {
    MyActionSheetView *photoPicker;
    MedicalReportPhotoCell *currentCell;
    NSIndexPath *currentIndexPath;
    
}


@end

@implementation MedicalReportAddNewViewController
@synthesize isActive;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的病历";
    [self customBackButton];
    [self setRightButtonHidden:NO];
    [picCollectionView registerNib:[UINib nibWithNibName:@"MedicalReportPhotoCell" bundle:nil] forCellWithReuseIdentifier:@"MedicalReportPhotoCell"];
    [self refreshActiveState];
    
    if (!iPhone5()) {
        [scView setContentSize:CGSizeMake(scView.frame.size.width, 530.f)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!picCollectionView.hidden && !photoPicker) {
        [self setNextImageUnitShow:YES];
        
        photoPicker = [[MyActionSheetView alloc] initWithPhotoSelectorStyle];
        photoPicker.delegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRightButtonHidden:(bool)isHidden {
    if (isHidden) {
        [self customNavigationBarItemWithImageName:nil isLeft:NO];
    }
    else {
        [self customNavigationBarItemWithTitleName:@"确定" isLeft:NO];
    }
}

#pragma mark - 提交
//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    
    
    if (tfTitle.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"请输入标题" cancelButton:String_Sure sureButton:nil];
        return;
    }
    if (tvContent.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"请输入内容" cancelButton:String_Sure sureButton:nil];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];
    NSString *action = @"saveOrUpdateMedicalRecordInfos.action";
    if (btn1.selected) {
        //病历
        [params setObject:tfTitle.text forKey:@"record_title"];
        [params setObject:tvContent.text forKey:@"record_content"];
        NSString *imgsLink = [self getAllImages];
        if (isValidString(imgsLink)) {
            [params setObject:imgsLink forKey:@"record_images"];
        }
        else {
            [self showAlertWithTitle:nil message:@"请添加图片" cancelButton:String_Sure sureButton:nil];
            return;
        }
    }
    else {
        //健康活动记录
        action = @"saveOrUpdateUserHealthActiveInfos.action";
        [params setObject:tfTitle.text forKey:@"active_theme"];
        [params setObject:tvContent.text forKey:@"active_desc"];
    }
    
    [self setRightButtonHidden:YES];
    [SVProgressHUD showWithStatus:String_Loading];
    [[AppsNetWorkEngine shareEngine] submitRequest:action param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:@"添加记录成功"];
            //返回不用清除了
//            tfTitle.text = @"";
//            tvContent.text = @"";
//            //清除图片
//            [self cleanupImages];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:1.f];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
            [self setRightButtonHidden:NO];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self setRightButtonHidden:NO];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

#pragma mark - Private
- (void)refreshActiveState {
    if (isActive) {
        //活动记录
        picCollectionView.hidden = YES;
        labelPic.hidden = YES;
        btn1.selected = NO;
        cursor1.hidden = YES;
        btn2.selected = YES;
        cursor2.hidden = NO;
    }
    else {
        //病历
        picCollectionView.hidden = NO;
        labelPic.hidden = NO;
        btn1.selected = YES;
        cursor1.hidden = NO;
        btn2.selected = NO;
        cursor2.hidden = YES;
    }
}


#pragma mark - Button Action
- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == 100) {
        isActive = NO;
    }
    else if (sender.tag == 101) {
        isActive = YES;
    }
    
    [self refreshActiveState];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    labelPlaceHolder.hidden = (textView.text.length > 0 || text.length > 0);
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    labelPlaceHolder.hidden = (textView.text.length > 0);
}

#pragma mark - For Images
///增加了一张图片后，会显示下一个加号
- (void)setNextImageUnitShow:(bool)show {
    NSIndexPath *nextIndexPath;
    if (!currentIndexPath) {
        nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else {
        if (currentIndexPath.row+1 < CollectionView_Col_Number) {
            nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row+1 inSection:currentIndexPath.section];
        }
        else {
            if (currentIndexPath.section+1 < CollectionView_Col_Number) {
                nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:currentIndexPath.section+1];
            }
            else {
                //已到最后一张，不可继续添加了
                return;
            }
        }
    }
    
    MedicalReportPhotoCell *cell = (MedicalReportPhotoCell*)[picCollectionView cellForItemAtIndexPath:nextIndexPath];
    cell.hidden = !show;
}

- (NSString*)getAllImages {
    NSMutableArray *imgs = [[NSMutableArray alloc] init];
    NSString *imgsLink = @"";
    //遍历cells
    for (int row = 0; row < CollectionView_Row_Number; row++) {
        for (int col = 0; col < CollectionView_Col_Number; col++) {
            MedicalReportPhotoCell *cell = (MedicalReportPhotoCell*)[picCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:col]];
            if (!cell.isHidden && isValidString(cell.mainImageLink)) {
                [imgs addObject:cell.mainImageLink];
                imgsLink = [imgsLink stringByAppendingFormat:@"%@,",cell.mainImageLink];
            }
        }
    }
    return imgsLink;
}

- (void)cleanupImages {
    //遍历cells
    for (int row = 0; row < CollectionView_Row_Number; row++) {
        for (int col = 0; col < CollectionView_Col_Number; col++) {
            MedicalReportPhotoCell *cell = (MedicalReportPhotoCell*)[picCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:col]];
            cell.mainImage = nil;
            cell.mainImageLink = nil;
            cell.hidden = YES;
        }
    }
    currentIndexPath = nil;
    [self setNextImageUnitShow:YES];
}


#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return CollectionView_Col_Number;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reusedIdentify = @"MedicalReportPhotoCell";
    MedicalReportPhotoCell *cell = (MedicalReportPhotoCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reusedIdentify forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }
    cell.backgroundColor = [UIColor clearColor];
//    //init cell
//    if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
//        NSInteger dataIndex = indexPath.section * CollectionView_Col_Number + indexPath.row;
//        NSLog(@"%d",dataIndex);
//        
//    }
    cell.hidden = YES;
    cell.delegate = self;
    
    [cell setupWithImage:nil];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return CollectionView_Row_Number;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(78, 78);
}
//定义每个UICollectionViewCell 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 2, 2);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSInteger selectedIndex = indexPath.section * CollectionView_Col_Number + indexPath.row;
    currentCell = (MedicalReportPhotoCell*)cell;
    currentIndexPath = indexPath;
    if (isValidString(currentCell.mainImageLink)) {//已选，查看大图
        // 1.封装图片数据
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        //遍历cells
        for (int row = 0; row < CollectionView_Row_Number; row++) {
            for (int col = 0; col < CollectionView_Col_Number; col++) {
                MedicalReportPhotoCell *cell = (MedicalReportPhotoCell*)[picCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:col]];
                if (!isValidString(cell.mainImageLink)) {
                    break;
                }
                MJPhoto *photo = [[MJPhoto alloc] init];
                photo.srcImageView = cell.imgvMain; // 来源于哪个UIImageView
                photo.image = cell.imgvMain.image;
                [photos addObject:photo];
            }
        }
        
        // 2.显示相册
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = selectedIndex; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        browser.delegate = self;
        [browser show];
    }
    else {
        [photoPicker show];
    }
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - MyActionSheetViewDelegate
- (void)btnDidClick:(int)buttonIndex {
    if (buttonIndex == 1) {
        //拍摄
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController * picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            picker.allowsEditing = NO;  //是否可编辑
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
    else if (buttonIndex == 2) {
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
}

#pragma mark - UINavigationControllerDelegate,UIImagePickerControllerDelegate
//拍摄完成后要执行的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [SVProgressHUD showWithStatus:@"正在保存图片..."];
    //得到图片
    __block UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *savePath = saveAndResizeImage(image, [NSString stringWithFormat:@"tmp_image_%@.png",getStringFromDate(@"yyyyMMddHHmmss", [NSDate date])],1600);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"正在上传图片..."];
            [[AppsNetWorkEngine shareEngine] uploadImagePath:savePath onCompletion:^(id jsonResponse) {
                [SVProgressHUD dismiss];
                if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
                    [SVProgressHUD showSuccessWithStatus:@"上传成功!"];
                    currentCell.mainImageLink = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"message"];
                    currentCell.mainImage = image;
                    [self setNextImageUnitShow:YES];
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
        NSLog(@"back to main vc.");
        
    }];
}

//点击Cancel按钮后执行方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"back to main vc.");
    }];
}

#pragma mark - MedicalReportPhotoCellDelegate
- (void)medicalReportPhotoCellDidDeleteImage:(MedicalReportPhotoCell*)mCell {
    NSMutableArray *imgs = [[NSMutableArray alloc] init];
    NSMutableArray *links = [[NSMutableArray alloc] init];
    //遍历cells
    for (int row = 0; row < CollectionView_Row_Number; row++) {
        for (int col = 0; col < CollectionView_Col_Number; col++) {
            MedicalReportPhotoCell *cell = (MedicalReportPhotoCell*)[picCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:col inSection:row]];
            if ([cell isEqual:mCell]) {
                continue;
            }
            if (!cell.isHidden && isValidString(cell.mainImageLink)) {
                [links addObject:cell.mainImageLink];
                [imgs addObject:cell.mainImage];
            }
        }
    }
    
    [self cleanupImages];
    
    for (int i = 0; i < imgs.count; i++) {
        int col = i/3;
        int row = i%3;
        MedicalReportPhotoCell *cell = (MedicalReportPhotoCell*)[picCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:col]];
        cell.hidden = NO;
        cell.mainImageLink = [links objectAtIndex:i];
        cell.mainImage = [imgs objectAtIndex:i];
        currentIndexPath = [NSIndexPath indexPathForRow:row inSection:col];
    }
    
    [self setNextImageUnitShow:YES];
}


@end
