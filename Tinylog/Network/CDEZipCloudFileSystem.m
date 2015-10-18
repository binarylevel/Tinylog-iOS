//
//  CDEZipCloudFileSystem.m
//  Idiomatic
//
//  Created by Drew McCormack on 12/06/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import "CDEZipCloudFileSystem.h"

static NSString * const CDEZipFilePathExtension = @"cdezip";

@implementation CDEZipCloudFileSystem {
    NSFileManager *fileManager;
    NSString *tempDirPath;
}

@synthesize cloudFileSystem = cloudFileSystem;

- (instancetype)initWithCloudFileSystem:(id <CDECloudFileSystem>)wrappedFileSystem
{
    self = [super init];
    if (self) {
        cloudFileSystem = wrappedFileSystem;
        fileManager = [[NSFileManager alloc] init];
        tempDirPath = [NSTemporaryDirectory() stringByAppendingFormat:@"/CDEZipCloudFileSystem/%@", [[NSProcessInfo processInfo] globallyUniqueString]];
        [self clearTempDir];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:CDEException reason:@"Wrong initializer invoked" userInfo:nil];
}

- (void)dealloc
{
    [[NSFileManager defaultManager] removeItemAtPath:tempDirPath error:NULL];
}

- (void)clearTempDir
{
    [fileManager removeItemAtPath:tempDirPath error:NULL];
    [fileManager createDirectoryAtPath:tempDirPath withIntermediateDirectories:YES attributes:nil error:NULL];
}

- (void)connect:(CDECompletionBlock)completion
{
    [cloudFileSystem connect:completion];
}

- (BOOL)isConnected
{
    return cloudFileSystem.isConnected;
}

- (void)fetchUserIdentityWithCompletion:(CDEFetchUserIdentityCallback)completion;
{
    [cloudFileSystem fetchUserIdentityWithCompletion:completion];
}

- (void)fileExistsAtPath:(NSString *)path completion:(CDEFileExistenceCallback)completion
{
    NSString *zippedPath = [path stringByAppendingPathExtension:CDEZipFilePathExtension];
    [cloudFileSystem fileExistsAtPath:zippedPath completion:^(BOOL exists, BOOL isDirectory, NSError *error) {
        if (error) {
            if (completion) completion(NO, NO, error);
            return;
        }
        
        if (!exists) {
            [cloudFileSystem fileExistsAtPath:path completion:completion];
            return;
        }
        
        if (completion) completion(exists, isDirectory, nil);
    }];
}

- (void)directoryExistsAtPath:(NSString *)path completion:(CDEDirectoryExistenceCallback)completion
{
    if ([cloudFileSystem respondsToSelector:@selector(directoryExistsAtPath:completion:)]) {
        [cloudFileSystem directoryExistsAtPath:path completion:^(BOOL exists, NSError *error) {
            if (completion) completion(error ? NO : exists, error);
        }];
    }
    else {
        [cloudFileSystem fileExistsAtPath:path completion:^(BOOL exists, BOOL isDirectory, NSError *error) {
            exists = exists && isDirectory;
            if (completion) completion(error ? NO : exists, error);
        }];
    }
}

- (void)createDirectoryAtPath:(NSString *)path completion:(CDECompletionBlock)completion
{
    [cloudFileSystem createDirectoryAtPath:path completion:completion];
}

- (void)removeItemAtPath:(NSString *)fromPath completion:(CDECompletionBlock)completion
{
    NSString *zippedPath = [fromPath stringByAppendingPathExtension:CDEZipFilePathExtension];
    [cloudFileSystem removeItemAtPath:zippedPath completion:^(NSError *zipFileError) {
        [cloudFileSystem removeItemAtPath:fromPath completion:^(NSError *nonZipError) {
            NSError *error = (zipFileError && nonZipError) ? nonZipError : nil;
            if (completion) completion(error);
        }];
    }];
}

- (void)removeItemsAtPaths:(NSArray *)paths completion:(CDECompletionBlock)block
{
    NSMutableArray *allPaths = [[NSMutableArray alloc] initWithArray:paths];
    for (NSString *path in paths) {
        NSString *zippedPath = [path stringByAppendingPathExtension:CDEZipFilePathExtension];
        [allPaths addObject:zippedPath];
    }
    
    [cloudFileSystem removeItemsAtPaths:allPaths completion:^(NSError *error) {
        // There can be errors due to zipped paths not existing, or vice versa. Ignore.
        if (block) block(nil);
    }];
}

- (void)contentsOfDirectoryAtPath:(NSString *)path completion:(CDEDirectoryContentsCallback)completion
{
    [cloudFileSystem contentsOfDirectoryAtPath:path completion:^(NSArray *contents, NSError *error) {
        if (error) {
            if (completion) completion(nil, error);
            return;
        }
        
        for (id item in contents) {
            CDECloudFile *file = item;
            if ([item isKindOfClass:[CDECloudFile class]] && [file.name.pathExtension isEqualToString:CDEZipFilePathExtension]) {
                file.name = [file.name stringByDeletingPathExtension];
            }
        }
        if (completion) completion(contents, nil);
    }];
}

- (NSString *)tempFilePath
{
    NSString *tempFilePath = [tempDirPath stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    return tempFilePath;
}

- (NSUInteger) fileDownloadMaximumBatchSize
{
    return [cloudFileSystem fileDownloadMaximumBatchSize];
}

- (void)downloadFromPath:(NSString *)fromPath toLocalFile:(NSString *)toPath completion:(CDECompletionBlock)completion
{
    NSString *tempFilePath = [self tempFilePath];
    NSString *zippedPath = [fromPath stringByAppendingPathExtension:CDEZipFilePathExtension];
    [cloudFileSystem downloadFromPath:zippedPath toLocalFile:tempFilePath completion:^(NSError *error) {
        if (error) {
            [cloudFileSystem downloadFromPath:fromPath toLocalFile:toPath completion:completion];
            return;
        }
        
        NSError *localError;
        NSString *destinationDir = [toPath stringByDeletingLastPathComponent];
        BOOL unzipSucceeded = [SSZipArchive unzipFileAtPath:tempFilePath toDestination:destinationDir overwrite:NO password:nil error:&localError];
        [fileManager removeItemAtPath:tempFilePath error:NULL];
        
        if (completion) completion(unzipSucceeded ? nil : localError);
    }];
}

- (void)downloadFromPaths:(NSArray *)fromPaths toLocalFiles:(NSArray *)toPaths completion:(CDECompletionBlock)completion
{
    NSMutableArray *tempPaths = [[NSMutableArray alloc] init];
    NSMutableArray *zippedPaths = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < fromPaths.count; i++) {
        NSString *fromPath = fromPaths[i];
        NSString *tempFilePath = [self tempFilePath];
        NSString *zippedPath = [fromPath stringByAppendingPathExtension:CDEZipFilePathExtension];
        [tempPaths addObject:tempFilePath];
        [zippedPaths addObject:zippedPath];
    }
    
    [cloudFileSystem downloadFromPaths:zippedPaths toLocalFiles:tempPaths completion:^(NSError *error) {
        if (error) {
            [cloudFileSystem downloadFromPaths:fromPaths toLocalFiles:toPaths completion:completion];
            return;
        }
        
        NSUInteger i = 0;
        NSError *localError = nil;
        BOOL unzipSucceeded = YES;
        for (NSString *tempFilePath in tempPaths) {
            NSString *toPath = toPaths[i++];
            NSString *destinationDir = [toPath stringByDeletingLastPathComponent];
            unzipSucceeded = [SSZipArchive unzipFileAtPath:tempFilePath toDestination:destinationDir overwrite:NO password:nil error:&localError];
            [fileManager removeItemAtPath:tempFilePath error:NULL];
            if (!unzipSucceeded) break;
        }
        
        if (completion) completion(unzipSucceeded ? nil : localError);
    }];
}

- (NSUInteger)fileUploadMaximumBatchSize
{
    return [cloudFileSystem fileUploadMaximumBatchSize];
}

- (void)uploadLocalFile:(NSString *)fromPath toPath:(NSString *)toPath completion:(CDECompletionBlock)completion
{
    NSString *tempFilePath = [self tempFilePath];
    [SSZipArchive createZipFileAtPath:tempFilePath withFilesAtPaths:@[fromPath]];
    NSString *zippedPath = [toPath stringByAppendingPathExtension:CDEZipFilePathExtension];
    [cloudFileSystem uploadLocalFile:tempFilePath toPath:zippedPath completion:^(NSError *error) {
        [fileManager removeItemAtPath:tempFilePath error:NULL];
        if (completion) completion(error);
    }];
}

- (void)uploadLocalFiles:(NSArray *)fromPaths toPaths:(NSArray *)toPaths completion:(CDECompletionBlock)completion
{
    NSMutableArray *tempPaths = [[NSMutableArray alloc] init];
    NSMutableArray *zippedPaths = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < fromPaths.count; i++) {
        NSString *fromPath = fromPaths[i];
        NSString *toPath = toPaths[i];
        NSString *tempFilePath = [self tempFilePath];
        [SSZipArchive createZipFileAtPath:tempFilePath withFilesAtPaths:@[fromPath]];
        NSString *zippedPath = [toPath stringByAppendingPathExtension:CDEZipFilePathExtension];
        [tempPaths addObject:tempFilePath];
        [zippedPaths addObject:zippedPath];
    }
    
    [cloudFileSystem uploadLocalFiles:tempPaths toPaths:zippedPaths completion:^(NSError *error) {
        for (NSString *tempPath in tempPaths) [fileManager removeItemAtPath:tempPath error:NULL];
        if (completion) completion(error);
    }];
}

#pragma mark Message Forwarding

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL result = NO;
    if (@selector(removeItemsAtPaths:completion:) == aSelector ||
        @selector(fileUploadMaximumBatchSize) == aSelector || @selector(uploadLocalFiles:toPaths:completion:) == aSelector ||
        @selector(fileDownloadMaximumBatchSize) == aSelector || @selector(downloadFromPaths:toLocalFiles:completion:) == aSelector ) {
        result = [cloudFileSystem respondsToSelector:aSelector];
    }
    else {
        result = [super respondsToSelector:aSelector];
    }
    return result;
}

@end
