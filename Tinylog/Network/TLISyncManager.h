//
//  TLISyncManager.h
//  Tinylog
//
//  Created by Spiros Gerokostas on 16/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ensembles/Ensembles.h>

extern NSString * const IDMSyncActivityDidBeginNotification;
extern NSString * const IDMSyncActivityDidEndNotification;

extern NSString * const IDMCloudServiceUserDefaultKey;
extern NSString * const IDMICloudService;

@interface IDMSyncManager : NSObject

@property (nonatomic, readonly, strong) CDEPersistentStoreEnsemble *ensemble;
@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, copy) NSString *storePath;

+ (instancetype)sharedSyncManager;

- (void)connectToSyncService:(NSString *)serviceId withCompletion:(CDECompletionBlock)completion;
- (void)disconnectFromSyncServiceWithCompletion:(CDECodeBlock)completion;

- (void)synchronizeWithCompletion:(CDECompletionBlock)completion;
- (BOOL)canSynchronize;

- (void)setup;
- (void)reset;

@end
