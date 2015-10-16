//
//  SGReachabilityController.h
//  SGReachability
//
//  Created by Spiros Gerokostas on 1/18/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface SGReachabilityController : NSObject

@property (nonatomic, strong) Reachability *reachability;

+ (SGReachabilityController *)sharedController;

+ (BOOL)isReachable;
+ (BOOL)isUnreachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

@end
