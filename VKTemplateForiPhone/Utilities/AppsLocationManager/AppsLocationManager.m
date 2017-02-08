//
//  AppsLocationManager.m
//  Fineland
//
//  Created by Rayco on 12-12-13.
//  Copyright (c) 2012年 Apps123. All rights reserved.
//

#import "AppsLocationManager.h"
#import "CoordinateConvertor.h"

@interface AppsLocationManager()<CLLocationManagerDelegate> {
    
}

@end

@implementation AppsLocationManager
@synthesize currentLocation = _currentLocation;
@synthesize lastTimeLocation = _lastTimeLocation;

#pragma mark - Public

+ (id)sharedManager {
    static AppsLocationManager *sharedAppsLocationManagerInstance;
    static dispatch_once_t onceAppsLocationManager;
    dispatch_once(&onceAppsLocationManager, ^{
        sharedAppsLocationManagerInstance = [[self alloc] init]; 
        
    });
    
    return sharedAppsLocationManagerInstance;
}

- (void)startUpdate {
    [_locationManager startUpdatingLocation];
}

- (void)stopUpdate {
    [_locationManager stopUpdatingLocation];
}

- (double)getDistance:(CLLocation*)_location {
    return [_currentLocation distanceFromLocation:_location];
}

#pragma mark - CLLocationManagerDelgate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _lastTimeLocation = _currentLocation;
    
    //转成火星标
    CLLocation *tmpLocation = [locations lastObject];
    CLLocationCoordinate2D coor = [CoordinateConvertor wgs84ToGcj02:tmpLocation.coordinate];
    _currentLocation = [[CLLocation alloc] initWithLatitude:coor.latitude longitude:coor.longitude];
//    NSLog(@"currentLocation:%@",_currentLocation);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    NSLog(@"%@",error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}

//ios8的新方法
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager  respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [_locationManager performSelector:@selector(requestAlwaysAuthorization)];
            }
            break;
        default:
            break;
    }
}

#pragma mark - lifecycle
- (id)init {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager performSelector:@selector(requestWhenInUseAuthorization)];
        }
        if([CLLocationManager locationServicesEnabled]){
            _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            _locationManager.delegate = self;
        }
        [self startUpdate];
    }
    return self;
}

@end
