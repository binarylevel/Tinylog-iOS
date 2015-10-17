//
//  TLISyncManager.m
//  Tinylog
//
//  Created by Spiros Gerokostas on 16/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Security/Security.h>

#import "TLISyncManager.h"

NSString * const IDMSyncActivityDidBeginNotification = @"IDMSyncActivityDidBegin";
NSString * const IDMSyncActivityDidEndNotification = @"IDMSyncActivityDidEnd";

NSString * const IDMCloudServiceUserDefaultKey = @"IDMCloudServiceUserDefaultKey";
NSString * const IDMICloudService = @"icloud";
NSString * const IDMICloudContainerIdentifier = @"iCloud.com.spirosgerokostas.Tinylog";

@interface TLISyncManager () <CDEPersistentStoreEnsembleDelegate>

@end

@implementation TLISyncManager {
    id <CDECloudFileSystem> cloudFileSystem;
    NSUInteger activeMergeCount;
}

@synthesize ensemble = ensemble;
@synthesize storePath = storePath;
@synthesize managedObjectContext = managedObjectContext;

+ (instancetype)sharedSyncManager {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TLISyncManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(icloudDidDownload:) name:CDEICloudFileSystemDidDownloadFilesNotification object:nil];
    }
    return self;
}

#pragma mark - Setting Up and Resetting

- (void)setup {
    [self setupEnsemble];
}

- (void)reset {
    ensemble.delegate = nil;
    ensemble = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IDMCloudServiceUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Connecting to a Backend Service

- (void)connectToSyncService:(NSString *)serviceId withCompletion:(CDECompletionBlock)completion {
    [[NSUserDefaults standardUserDefaults] setObject:serviceId forKey:IDMCloudServiceUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setupEnsemble];
    [self synchronizeWithCompletion:completion];
}

- (void)disconnectFromSyncServiceWithCompletion:(CDECodeBlock)completion
{
    [ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
        [self reset];
        if (completion) completion();
    }];
}

#pragma mark - Persistent Store Ensemble

- (void)setupEnsemble
{
    if (!self.canSynchronize) return;
    
    cloudFileSystem = [self makeCloudFileSystem];
    if (!cloudFileSystem) return;
    
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tinylog" withExtension:@"momd"];
    ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"MainStore" persistentStoreURL:storeURL managedObjectModelURL:modelURL cloudFileSystem:cloudFileSystem];
    ensemble.delegate = self;
}

- (id <CDECloudFileSystem>)makeCloudFileSystem {
    NSString *cloudService = [[NSUserDefaults standardUserDefaults] stringForKey:IDMCloudServiceUserDefaultKey];
    id <CDECloudFileSystem> newSystem = nil;
    if ([cloudService isEqualToString:IDMICloudService]) {
        newSystem = [[CDEICloudFileSystem alloc] initWithUbiquityContainerIdentifier:IDMICloudContainerIdentifier];
    }
    return newSystem;
}

#pragma mark - Sync Methods

- (void)icloudDidDownload:(NSNotification *)notif {
    [self synchronizeWithCompletion:NULL];
}

- (BOOL)canSynchronize {
    NSString *cloudService = [[NSUserDefaults standardUserDefaults] stringForKey:IDMCloudServiceUserDefaultKey];
    return cloudService != nil;
}

- (void)synchronizeWithCompletion:(CDECompletionBlock)completion {
    if (!self.canSynchronize) return;
    
    [self incrementMergeCount];
    if (!ensemble.isLeeched) {
        [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
            [self decrementMergeCount];
            if (error && !ensemble.isLeeched) {
                NSLog(@"Could not leech to ensemble: %@", error);
                [self disconnectFromSyncServiceWithCompletion:^{
                    if (completion) completion(error);
                }];
            } else {
                if (completion) completion(error);
            }
        }];
    }
    else {
        [ensemble mergeWithCompletion:^(NSError *error) {
            [self decrementMergeCount];
            if (error) NSLog(@"Error merging: %@", error);
            if (completion) completion(error);
        }];
    }
}

- (void)decrementMergeCount
{
    activeMergeCount--;
    if (activeMergeCount == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IDMSyncActivityDidEndNotification object:nil];
    }
}

- (void)incrementMergeCount
{
    activeMergeCount++;
    if (activeMergeCount == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IDMSyncActivityDidBeginNotification object:nil];
    }
}

#pragma mark - Persistent Store Ensemble Delegate

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didSaveMergeChangesWithNotification:(NSNotification *)notification {
    [managedObjectContext performBlock:^{
        [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

- (NSArray *)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble globalIdentifiersForManagedObjects:(NSArray *)objects {
    return [objects valueForKeyPath:@"uniqueIdentifier"];
}

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didDeleechWithError:(NSError *)error {
    NSLog(@"Store did deleech with error: %@", error);
    [self reset];
}

@end

