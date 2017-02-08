//
//  ReverseLocationControl.m
//  AppsTemplate
//
//

#import "ReverseLocationControl.h"
#import "AppsLocationManager.h"

@implementation ReverseLocationControl


- (id)init{
    
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)reverLocation{

    CLLocation *location = [[AppsLocationManager sharedManager] currentLocation];
    if (!location) {
        cityString = @"未知";
        [_delegate reverseLocationStringSuccess:cityString];
    }else{
        search = [[AMapSearchAPI alloc] initWithSearchKey:MAP_KEY Delegate:nil];
        
        AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
        
        regeo.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        regeo.requireExtension = YES;
        
        [search AMapReGoecodeSearch:regeo];
        search.delegate = self;
    }
}

#pragma mark - AMapSearchDelegate
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        NSLog(@"%@",response.regeocode.formattedAddress);
        if ([self.delegate respondsToSelector:@selector(reverseLocationStringSuccess:)]) {
            [self.delegate reverseLocationStringSuccess:response.regeocode.formattedAddress];
        }
    }
}


@end
