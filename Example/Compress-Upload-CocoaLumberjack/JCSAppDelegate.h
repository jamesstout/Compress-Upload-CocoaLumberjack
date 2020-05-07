//
//  JCSAppDelegate.h
//  Compress-Upload-CocoaLumberjack
//
//  Created by jamesstout on 05/07/2020.
//  Copyright (c) 2020 jamesstout. All rights reserved.
//

@import UIKit;
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <Compress-Upload-CocoaLumberjack/CompressingAndUploadingLogFileManager.h>

extern const DDLogLevel ddLogLevel;;

@interface JCSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) CompressingAndUploadingLogFileManager *logFileManager;
@end

