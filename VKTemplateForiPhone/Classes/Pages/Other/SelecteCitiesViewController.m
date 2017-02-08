//
//  SelecteCitiesViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/2/8.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "SelecteCitiesViewController.h"
#import "AppsLocationManager.h"
#import "UserSessionCenter.h"


@interface SelecteCitiesViewController ()<UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray *dataSource;
    NSString *currentCityName;
    NSDictionary *currentCityInfo;
}

@end

@implementation SelecteCitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"切换城市";
    [self customBackButton];
    currentCityName = @"定位中...";
    [self locateCity];
    [self getCityList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)locateCity {
    CLLocation *currentLocation = [[AppsLocationManager sharedManager] currentLocation];
    NSString *geoLink = [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder?location=%lf,%lf&output=json&key=16040cc28c6784d6d17ef30bfd9f31ce",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
    [[AppsNetWorkEngine shareEngine] submitFullLinkRequest:geoLink onCompletion:^(id jsonResponse) {
        if ([[[jsonResponse objectForKey:@"status"] lowercaseString] isEqualToString:@"ok"]) {
            NSDictionary *addrInfo = [[jsonResponse objectForKey:@"result"] objectForKey:@"addressComponent"];
            if (isValidString([addrInfo objectForKey:@"city"])) {
                currentCityName = [addrInfo objectForKey:@"city"];
            }
            else {
                currentCityName = String_Cannot_Locate;
            }
            [tbView reloadData];
        }
    } onError:^(NSError *error) {
        
    } method:@"GET"];
}

- (void)getCityList {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@1,@"status", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getOpenCityList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [self showNoData:NO];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            if (isValidArray([jsonResponse objectForKey:@"rows"])) {
                dataSource = [[NSMutableArray alloc] initWithArray:[jsonResponse objectForKey:@"rows"]];
                [tbView reloadData];
            }
            else {
                [self showNoData:YES];
            }
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:@"确定" sureButton:nil];
            [self showNoData:YES];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (NSDictionary*)searchCityInfoByName:(NSString*)cityName {
    cityName = [cityName stringByReplacingOccurrencesOfString:@"市" withString:@""];
    for (NSInteger i = 0; i < dataSource.count; i++) {
        NSDictionary *dic = [dataSource objectAtIndex:i];
        NSString *str = [dic objectForKey:@""];
        str = [str stringByReplacingOccurrencesOfString:@"市" withString:@""];
        if ([str isEqualToString:cityName]) {
            return dic;
        }
    }
    return nil;
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return [dataSource count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reusedIdentify = @"PureTextCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentify];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    //init cell
    if (indexPath.section < dataSource.count) {
        if ([cell respondsToSelector:@selector(setCellDataInfo:)]) {
            NSString *cityName = @"";
            if (indexPath.section == 0) {
                cityName = currentCityName;
            }
            else {
                NSDictionary *dic = [dataSource objectAtIndex:indexPath.row];
                if (isValidDictionary(dic)) {
                    cityName = [dic objectForKey:@"city_name"];
                }
            }
            [cell performSelector:@selector(setCellDataInfo:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:cityName,@"title", nil]];
        }
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30.0f)];
    hView.backgroundColor = [UIColor whiteColor];
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0, hView.frame.size.width - 20.0f, hView.frame.size.height)];
    if (section == 0) {
        labelTitle.text = @"定位到的城市";
    }
    else {
        labelTitle.text = @"已开通的城市";
    }
    labelTitle.textColor = GetColorWithRGB(252, 30, 184);
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    [hView addSubview:labelTitle];
    
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, hView.frame.size.height-1, hView.frame.size.width, 1.0f)];
    viewLine.backgroundColor = GetColorWithRGB(230, 230, 230);
    [hView addSubview:viewLine];
    return hView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select at row:%d",indexPath.row);
    [UIView animateWithDuration:0.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    NSDictionary *dic = [dataSource objectAtIndex:indexPath.row];
    if (indexPath.section == 0) {
        //选择了自动定位到的城市
        if ([currentCityName isEqualToString:String_Cannot_Locate]) {
            //定位不到
            return;
        }
        
        currentCityInfo = [self searchCityInfoByName:currentCityName];
        if (!isValidDictionary(currentCityInfo)) {
            //定位到未开通的城市
            [self showAlertWithTitle:@"温馨提示" message:@"当前城市尚未开通服务" cancelButton:String_Sure sureButton:nil];
            return;
        }
        dic = currentCityInfo;
    }
    [[UserSessionCenter shareSession] saveUserCityInfo:dic];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
