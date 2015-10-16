//
//  SGReachabilityController.m
//  SGReachability
//
//  Created by Spiros Gerokostas on 1/18/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "SGReachabilityController.h"
#import "Reachability.h"

@implementation SGReachabilityController

@synthesize reachability = _reachability;

#pragma mark - Singleton

+ (SGReachabilityController *)sharedController
{
    static SGReachabilityController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[self alloc] init];
    });
    return sharedController;
}

#pragma mark - NSObject

- (void)dealloc
{
    if (_reachability)
    {
        [_reachability stopNotifier];
    }
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        _reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
        [_reachability startNotifier];
    }
    return self;
}

#pragma mark - Static Methods

+ (BOOL)isReachable
{
    return [[[SGReachabilityController sharedController] reachability] isReachable];
}

+ (BOOL)isUnreachable
{
    return ![[[SGReachabilityController sharedController] reachability] isReachable];
}

+ (BOOL)isReachableViaWWAN
{
    return [[[SGReachabilityController sharedController] reachability] isReachableViaWWAN];
}

+ (BOOL)isReachableViaWiFi
{
    return [[[SGReachabilityController sharedController] reachability] isReachableViaWiFi];
}

@end
