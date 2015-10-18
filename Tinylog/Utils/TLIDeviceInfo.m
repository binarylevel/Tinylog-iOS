//
//  TLIDeviceInfo.m
//  Tinylog
//
//  Created by Spiros Gerokostas on 3/27/15.
//  Copyright (c) 2015 Spiros Gerokostas. All rights reserved.
//

#import "TLIDeviceInfo.h"
#import <sys/utsname.h>

@implementation TLIDeviceInfo

+ (NSString *)model {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString: systemInfo.machine encoding: NSUTF8StringEncoding];
}

@end
