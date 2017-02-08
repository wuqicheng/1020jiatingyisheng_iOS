//
//  AppsLocationManager.h
//  Fineland
//
//  Created by Rayco on 12-12-13.
//  Copyright (c) 2012年 Apps123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AppsLocationManager : NSObject {
    CLLocationManager *_locationManager;
}

@property(copy) CLLocation *currentLocation;
@property(copy) CLLocation *lastTimeLocation;

+ (id)sharedManager;

- (void)startUpdate;

- (void)stopUpdate;

- (double)getDistance:(CLLocation*)_location;

@end