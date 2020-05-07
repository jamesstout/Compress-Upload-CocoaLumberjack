//
//  JCSViewController.m
//  Compress-Upload-CocoaLumberjack
//
//  Created by jamesstout on 05/07/2020.
//  Copyright (c) 2020 jamesstout. All rights reserved.
//

#import "JCSViewController.h"
#import "JCSAppDelegate.h"

@interface JCSViewController ()
@end

@implementation JCSViewController

@synthesize label, tv;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    DDFileLogger *fileLogger = ((JCSAppDelegate *)UIApplication.sharedApplication.delegate).fileLogger;
    
    DDLogVerbose(@"fileLogger log folder: %@", fileLogger.logFileManager.logsDirectory);
    
    self.tv.text = fileLogger.logFileManager.logsDirectory;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
