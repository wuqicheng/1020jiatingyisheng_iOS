//
//  PickAddressActionSheetView.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/3.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "PickAddressActionSheetView.h"

@implementation PickAddressActionSheetView
@synthesize provinces,cities,districts,delegate;
@synthesize selectedAddress = _selectedAddress;

- (instancetype)initWithTitle:(NSString*)pTitle pickerType:(PickAddressActionSheetViewType)type {
    self = [self initWithFrame:[AppKeyWindow bounds]];
    if (self) {
        [self setUpViewWithTitle:pTitle];
    }
    return self;
}

- (void)show {
    [AppKeyWindow addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}

#pragma mark - Private
- (void)setUpViewWithTitle:(NSString*)pTitle {
    self.backgroundColor = [UIColor clearColor];
    
    //make a mask-view
    UIView *viewMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    viewMask.backgroundColor = [UIColor blackColor];
    viewMask.alpha = 0.6;
    [self addSubview:viewMask];
    
    [self readAreaList];
    
    if (!aPickerView) {
        float topbarHeight = 30.f,pickerHeight = 162.f;
        pickerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-(topbarHeight+pickerHeight), self.frame.size.width, topbarHeight+pickerHeight)];
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
        aPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,viewTopBar.frame.size.height, pickerContainer.frame.size.width, pickerHeight)];
        aPickerView.delegate = self;
        aPickerView.dataSource = self;
        aPickerView.backgroundColor = [UIColor whiteColor];
        [aPickerView selectRow:0 inComponent:1 animated:NO];
        
        [pickerContainer addSubview:viewTopBar];
        [pickerContainer addSubview:aPickerView];
        [self addSubview:pickerContainer];
    }
    
}

- (void)readAreaList {
    NSString *configPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"area.json"];
    NSString *str = [[NSString alloc] initWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:nil];
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSError *error;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"#### Error--AppsEngine->toValue:%@",error);
    }
    
    if (isValidArray(arr)) {
        provinces = [[NSMutableArray alloc] initWithArray:arr];
        cities = [[NSMutableArray alloc] initWithArray:[[provinces firstObject] objectForKey:@"cityList"]];
        districts = [[NSMutableArray alloc] initWithArray:[[cities firstObject] objectForKey:@"distinctList"]];
    }
}

- (IBAction)topBarAction:(UIButton*)sender {
    [self dismiss];
    if (sender.tag == 101) {
        //YES
        NSDictionary* selectedProvince = [provinces objectAtIndex:[aPickerView selectedRowInComponent:0]];
        NSDictionary* selectedCity = [cities objectAtIndex:[aPickerView selectedRowInComponent:1]];
        NSDictionary* selectedDistrict = [districts objectAtIndex:[aPickerView selectedRowInComponent:2]];
        PickAddressItem *aItem = [[PickAddressItem alloc] init];
        aItem.provinceId = [selectedProvince objectForKey:@"id"];
        aItem.provinceName = [selectedProvince objectForKey:@"area_name"];
        aItem.cityId = [selectedCity objectForKey:@"id"];
        aItem.cityName = [selectedCity objectForKey:@"area_name"];
        aItem.districtId = [selectedDistrict objectForKey:@"id"];
        aItem.districtName = [selectedDistrict objectForKey:@"area_name"];
        
        if ([delegate respondsToSelector:@selector(pickAddressActionSheetView:didSelectAddress:)]) {
            [delegate pickAddressActionSheetView:self didSelectAddress:aItem];
        }
    }
}


#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return provinces.count;
    }
    else if (component == 1) {
        return cities.count;
    }
    else {
        return districts.count;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *dic;
    if (component == 0) {//选择省份
        dic = [provinces objectAtIndex:row];
    }
    else if (component == 1) {//选择城市
        dic = [cities objectAtIndex:row];
    }
    else {//选择区域
        dic = [districts objectAtIndex:row];
    }
    
    return [dic objectForKey:@"area_name"];
}

//监听轮子的移动
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        cities = [[NSMutableArray alloc] initWithArray:[[provinces objectAtIndex:row] objectForKey:@"cityList"]];
        
        //重点！更新第二个轮子的数据
        [pickerView selectRow:2 inComponent:1 animated:NO];
        [pickerView reloadComponent:1];
        
    }
    else if (component == 1) {
        districts = [[NSMutableArray alloc] initWithArray:[[cities objectAtIndex:row] objectForKey:@"distinctList"]];
        //重点！更新第二个轮子的数据
        [pickerView selectRow:2 inComponent:2 animated:NO];
        [pickerView reloadComponent:2];
    }
}


@end
