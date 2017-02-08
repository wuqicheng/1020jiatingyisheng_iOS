//
//  AddressBookViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/2/28.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AddressBookViewController.h"
#import "UserSessionCenter.h"
#import "PureTextCell.h"

@interface AddressBookViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray *dataSource,*cityArray,*districtArray,*tmpArr;
    NSDictionary *selectedCity,*selectedDistrict;
    NSIndexPath *indexPathToDelete;
    UIView *maskView;
    PureTextCell *sampleCell;
}
@end

@implementation AddressBookViewController
@synthesize selectable,selectedInfo,delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"服务地址";
    [self customBackButton];
    [self customNavigationBarItemWithTitleName:@"确定" isLeft:NO];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView {
    sampleCell = [[[NSBundle mainBundle] loadNibNamed:@"PureTextCell" owner:self options:nil] objectAtIndex:0];
    
    cityArray = [[NSMutableArray alloc] init];
    districtArray = [[NSMutableArray alloc] init];
    tmpArr = [[NSMutableArray alloc] init];
    
    [self getCityAndDistrictData];
    [self getUserAddressList];
    
    //@"广州",@"北京",@"深圳",@"上海", nil
//    NSArray *arr1 = [NSArray arrayWithObjects:@"天河区",@"越秀区",@"番禺区",@"荔湾区",@"海珠区", nil];
//    NSArray *arr2 = [NSArray arrayWithObjects:@"东城区",@"西城区",@"崇文区",@"宣武区",@"朝阳区",@"海淀区",@"房山区", nil];
//    NSArray *arr3 = [NSArray arrayWithObjects:@"罗湖区",@"福田区",@"南山区",@"盐田区",@"宝安区",@"龙岗区", nil];
//    NSArray *arr4 = [NSArray arrayWithObjects:@"徐汇区",@"长宁区",@"普陀区",@"闸北区",@"虹口区",@"杨浦区",@"黄浦区", nil];
//    tmpArr = [NSMutableArray arrayWithObjects:arr1,arr2,arr3,arr4, nil];
//    NSArray *arrc = @[@"广州",@"北京",@"深圳",@"上海"];
//    for (int i = 0; i < 4; i++) {
//        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[tmpArr objectAtIndex:i],@"row", nil];
//        [cityArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:dic,[arrc objectAtIndex:i], nil]];
//    }
//    
//    
//    cityArray = [NSMutableArray arrayWithObjects:@"广州",@"北京",@"深圳",@"上海", nil];
//    districtArray = [[NSMutableArray alloc] initWithArray:arr1];
}

- (void)showNoDataView {
    [super showNoData:YES];
}

- (void)getCityAndDistrictData {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@1,@"status", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getOpenCityAndDistinctList.action" param:params onCompletion:^(id jsonResponse) {
        if (isValidArray([jsonResponse objectForKey:@"rows"])) {
            cityArray = [NSMutableArray arrayWithArray:[jsonResponse objectForKey:@"rows"]];
            districtArray = [self getDistrictDataByIndex:0];
        }
    } onError:^(NSError *error) {
        
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

- (void)getUserAddressList {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id",@1,@"status",nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getUserAddressList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self showNoData:NO];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            if (isValidArray([jsonResponse objectForKey:@"rows"])) {
                dataSource = [[NSMutableArray alloc] initWithArray:[jsonResponse objectForKey:@"rows"]];
                [tbView reloadData];
            }
            else {
                [self showNoDataWithTips:@"暂无常用地址"];
                [self nodataViewShowFrame:CGRectMake(10, 160, 100, 30)];
            }
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
            [self showNoDataWithTips:@"暂无常用地址"];
            [self nodataViewShowFrame:CGRectMake(10, 160, 100, 30)];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self showNoDataWithTips:@"暂无常用地址"];
        [self nodataViewShowFrame:CGRectMake(10, 160, 100, 30)];
    } defaultErrorAlert:YES isCacheNeeded:YES method:nil];
}

//返回键响应函数，重写此函数，实现返回前执行一系列操作
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    NSLog(@"need to implement this methor");
    if (labelO.text.length < 1) {
        [self showAlertWithTitle:nil message:@"请选择地区" cancelButton:String_Sure sureButton:nil];
        return;
    }
    if (tfDetail.text.length < 1) {
        [self showAlertWithTitle:nil message:@"请填写详细地址" cancelButton:String_Sure sureButton:nil];
        return;
    }
    
    [tfDetail resignFirstResponder];
    
    [SVProgressHUD showWithStatus:String_Saving];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@%@",labelO.text,tfDetail.text],@"address",
                                   [[UserSessionCenter shareSession] getUserId],@"user_id",
                                   @1,@"status",nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"addOrUpDateUserAddress.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:String_Saved_Success];
            
            labelO.text = @"";
            tfDetail.text = @"";
            selectedDistrict = nil;
            selectedCity = nil;
            
            [self performSelector:@selector(getUserAddressList) withObject:nil afterDelay:0.5];
        }
        else {
            [self showAlertWithTitle:@"保存失败" message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

#pragma mark - Picker
- (void)showPicker {
//    self.locatePicker = [[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCity delegate:self];
//    self.locatePicker = [[HZAreaPickerView alloc] initWithDataSouce:cityArray style:HZAreaPickerWithCityAndDistrict delegate:self];
    
    UIView *fatherView = self.view;
    if (!maskView) {//
        maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fatherView.frame.size.width, fatherView.frame.size.height)];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.6;
    }
    [fatherView addSubview:maskView];
    
    if (!pickerViewCity) {
        float topbarHeight = 30.f,pickerHeight = 162.f;
        pickerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, fatherView.frame.size.height, fatherView.frame.size.width, topbarHeight+pickerHeight)];
        pickerContainer.backgroundColor = [UIColor whiteColor];
        
        //make up top-bar
        UIView *viewTopBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pickerContainer.frame.size.width, topbarHeight)];
        viewTopBar.backgroundColor = [UIColor whiteColor];

        UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 0, 60.0, viewTopBar.frame.size.height)];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(topBarAction:) forControlEvents:UIControlEventTouchUpInside];
        btnCancel.tag = 100;
        [viewTopBar addSubview:btnCancel];
        
        UIButton *btnYes = [[UIButton alloc] initWithFrame:CGRectMake(viewTopBar.frame.size.width - 10.0 - 60.0, 0, 60.0, viewTopBar.frame.size.height)];
        [btnYes setTitle:@"确定" forState:UIControlStateNormal];
        [btnYes setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btnYes addTarget:self action:@selector(topBarAction:) forControlEvents:UIControlEventTouchUpInside];
        btnYes.tag = 101;
        [viewTopBar addSubview:btnYes];
        
        UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, viewTopBar.frame.size.height-1.0f, viewTopBar.frame.size.width, 1.0f)];
        viewLine.backgroundColor = GetColorWithRGB(230, 230, 230);
        [viewTopBar addSubview:viewLine];
        
        //make up picker
        pickerViewCity = [[UIPickerView alloc] initWithFrame:CGRectMake(0,viewTopBar.frame.size.height, pickerContainer.frame.size.width, pickerHeight)];
        pickerViewCity.delegate = self;
        pickerViewCity.dataSource = self;
        pickerViewCity.backgroundColor = [UIColor whiteColor];
        [pickerViewCity selectRow:0 inComponent:1 animated:NO];
        
        [pickerContainer addSubview:viewTopBar];
        [pickerContainer addSubview:pickerViewCity];
//        [self.locatePicker showInView:pickerContainer];
    }
    
    [fatherView addSubview:pickerContainer];
    [UIView animateWithDuration:0.2 animations:^{
        setViewFrameOriginY(pickerContainer, fatherView.frame.size.height-pickerContainer.frame.size.height);
    }];
}

- (void)hidePicker {
    UIView *fatherView = KEY_WINDOW;
    [UIView animateWithDuration:0.2 animations:^{
        setViewFrameOriginY(pickerContainer, fatherView.frame.size.height);
    } completion:^(BOOL finished) {
        [maskView removeFromSuperview];
    }];
}

- (IBAction)topBarAction:(UIButton*)sender {
    [self hidePicker];
//    [self cancelLocatePicker];
    if (sender.tag == 101) {
        //YES
        selectedCity = [cityArray objectAtIndex:[pickerViewCity selectedRowInComponent:0]];
        selectedDistrict = [districtArray objectAtIndex:[pickerViewCity selectedRowInComponent:1]];
        
        labelO.text = [NSString stringWithFormat:@"%@%@",[selectedCity objectForKey:@"city_name"],[selectedDistrict objectForKey:@"distinct_name"]];
    }
}

- (NSMutableArray*)getDistrictDataByIndex:(NSInteger)cIndex {
    NSMutableArray *arr;
    if (cIndex < cityArray.count) {
        arr = [NSMutableArray arrayWithArray:[[cityArray objectAtIndex:cIndex] objectForKey:@"distinctList"]];
    }
    if (!isValidArray(arr)) {
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"无",@"distinct_name", nil];
        arr = [NSMutableArray arrayWithObjects:dic, nil];
    }
    
    return arr;
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return cityArray.count;
    }
    else {
        return districtArray.count;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {//选择城市
        return [[cityArray objectAtIndex:row] objectForKey:@"city_name"];
    } else {//选择区域
        return [[districtArray objectAtIndex:row] objectForKey:@"distinct_name"];
    }
}

//监听轮子的移动
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
//        NSString *seletedCity = [cityArray objectAtIndex:row];
        districtArray = [self getDistrictDataByIndex:row];
        
        //重点！更新第二个轮子的数据
        [pickerView selectRow:2 inComponent:1 animated:NO];
        [pickerView reloadComponent:1];
        
        
//        NSInteger selectedDistrictIndex = [pickerView selectedRowInComponent:1];
//        NSString *seletedDistrict = [districtArray objectAtIndex:selectedDistrictIndex];
//        
//        NSString *msg = [NSString stringWithFormat:@"city=%@,district=%@",seletedCity,seletedDistrict];
//        NSLog(@"%@",msg);
    }
    else {
//        NSInteger selectedCityIndex = [pickerView selectedRowInComponent:0];
//        NSString *seletedCity = [cityArray objectAtIndex:selectedCityIndex];
//        
//        NSString *seletedDistrict = [districtArray objectAtIndex:row];
//        NSString *msg = [NSString stringWithFormat:@"city=%@,district=%@", seletedCity,seletedDistrict];
//        NSLog(@"%@",msg);
    }
}

- (void)selectedItemInTableView:(NSIndexPath*)indexPath {
    [tbView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    else {
        if (dataSource.count <= 0) {
            [tbView setScrollEnabled:NO];
        }
    }
    return dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cellFinal;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cellFinal = cell1;
        }
        else {
            cell2.selectionStyle = UITableViewCellSelectionStyleNone;
            cellFinal = cell2;
        }
    }
    else {
        NSString *reusedIdentify = @"PureTextCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //init cell
        if (indexPath.row < dataSource.count) {
            if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"address"],@"title", nil];
                [cell performSelector:@selector(setCellDataInfo:) withObject:dic];
            }
        }
        
        if (isValidDictionary(selectedInfo) && [[selectedInfo objectForKey:@"address_id"] integerValue] == [[[dataSource objectAtIndex:indexPath.row] objectForKey:@"address_id"] integerValue]) {
            [self performSelector:@selector(selectedItemInTableView:) withObject:indexPath afterDelay:0.5f];
        }

        
        cellFinal = cell;
    }
    
    cellFinal.backgroundColor = [UIColor whiteColor];
    return cellFinal;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30.0f)];
    hView.backgroundColor = [UIColor clearColor];
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0, hView.frame.size.width - 20.0f, hView.frame.size.height)];
    if (section == 0) {
        labelTitle.text = @"新增地区";
    }
    else {
        labelTitle.text = @"常用地区";
    }
    labelTitle.textColor = GetColorWithRGB(150, 150, 150);
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    [hView addSubview:labelTitle];
    
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, hView.frame.size.height-1, hView.frame.size.width, 1.0f)];
    viewLine.backgroundColor = GetColorWithRGB(239, 239, 239);
    [hView addSubview:viewLine];
    return hView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
         NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"address"],@"title", nil];
        CGFloat cHeight = [sampleCell heigthForCell:dic];
        NSLog(@"cell height:%f",cHeight);
        return cHeight;
    }
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select at row:%d",indexPath.row);
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self showPicker];
    }
    [tfDetail resignFirstResponder];
    
    if (indexPath.section == 1) {
        if ([delegate respondsToSelector:@selector(addressbookViewController:selectedInfo:)]) {
            [delegate addressbookViewController:self selectedInfo:[dataSource objectAtIndex:indexPath.row]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        indexPathToDelete = indexPath;
        [self showAlertWithTitle:nil message:@"确定要删除该地址？" cancelButton:@"删除" sureButton:@"取消"];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (!indexPathToDelete) {
            return;
        }
        NSDictionary *dic = [dataSource objectAtIndex:indexPathToDelete.section];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[dic objectForKey:@"address_id"],@"address_id", nil];
        [SVProgressHUD showWithStatus:@"删除中..."];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"deleteAddressById.action" param:params onCompletion:^(id jsonResponse) {
            if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
                [SVProgressHUD showSuccessWithStatus:@"删除成功!"];
                [dataSource removeObjectAtIndex:indexPathToDelete.section];
                [tbView deleteSections:[NSIndexSet indexSetWithIndex:indexPathToDelete.section] withRowAnimation:UITableViewRowAnimationFade];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"删除失败，请重试!"];
            }
        } onError:^(NSError *error) {
            
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }
}

@end
