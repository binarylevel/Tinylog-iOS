//
//  CDEZipCloudFileSystem.h
//  Ensembles
//
//  This class is not a standard file system. It is used to wrap an existing
//  file system, and zip compress any files going into it.
//  It will unzip files coming from the cloud as needed.
//
//  Created by Drew McCormack on 12/06/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ensembles/Ensembles.h>
#import "SSZipArchive.h"

@interface CDEZipCloudFileSystem : NSObject <CDECloudFileSystem>

@property (nonatomic, readonly) id <CDECloudFileSystem> cloudFileSystem;

- (instancetype)initWithCloudFileSystem:(id <CDECloudFileSystem>)wrappedFileSystem;

@end
