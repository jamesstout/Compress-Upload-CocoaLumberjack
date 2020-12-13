//
//  CompressingAndUploadingLogFileManager.m
//  LogFileCompressor
//
//  Based on CocoaLumberjack Demos
//  and BackgroundUpload-CocoaLumberjack: https://github.com/pushd/BackgroundUpload-CocoaLumberjack
//

#import "CompressingAndUploadingLogFileManager.h"
#import <zlib.h>
#import <UIKit/UIKit.h>

// We probably shouldn't be using DDLog() statements within the DDLog implementation.
// But we still want to leave our log statements for any future debugging,
// and to allow other developers to trace the implementation (which is a great learning tool).
// 
// So we use primitive logging macros around NSLog.
// We maintain the NS prefix on the macros to be explicit about the fact that we're using NSLog.

#define LOG_LEVEL 2

#define NSLogError(frmt, ...)    do{ if(LOG_LEVEL >= 1) NSLog(frmt, ##__VA_ARGS__); } while(0)
#define NSLogWarn(frmt, ...)     do{ if(LOG_LEVEL >= 2) NSLog(frmt, ##__VA_ARGS__); } while(0)
#define NSLogInfo(frmt, ...)     do{ if(LOG_LEVEL >= 3) NSLog(frmt, ##__VA_ARGS__); } while(0)
#define NSLogVerbose(frmt, ...)  do{ if(LOG_LEVEL >= 4) NSLog(frmt, ##__VA_ARGS__); } while(0)

@interface CompressingAndUploadingLogFileManager (/* Must be nameless for properties */)

@property (readwrite) BOOL isCompressing;
@property (strong, nonatomic) NSURLRequest *uploadRequest;

// discretionary prevents uploading unless on wi-fi even if log is rolled in foreground
@property (assign, nonatomic) BOOL discretionary;
@property (weak, nonatomic) id<JCSBackgroundUploadLogFileManagerDelegate> delegate;

@property (strong, nonatomic) NSURLSession *session;
@property (copy, nonatomic) void(^completionHandler)(void);
@property (nonatomic, readwrite, strong) NSFileManager *fileManager;

@end

@interface DDLogFileInfo (Compressor)

@property (nonatomic, readonly) BOOL isCompressed;

- (NSString *)tempFilePathByAppendingPathExtension:(NSString *)newExt;
- (NSString *)fileNameByAppendingPathExtension:(NSString *)newExt;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CompressingAndUploadingLogFileManager

@synthesize isCompressing, doUpload, fileManager;

- (id)initWithUploadRequest:(NSURLRequest *)uploadRequest
{
    return [self initWithLogsDirectory:nil andUploadRequest:uploadRequest];
}

- (id)initWithLogsDirectory:(NSString *)aLogsDirectory andUploadRequest:(NSURLRequest *)uploadRequest
{
    if ((self = [super initWithLogsDirectory:aLogsDirectory]))
    {
        upToDate = NO;
        
        _uploadRequest = uploadRequest;
        _discretionary = YES;
        doUpload = YES;
        fileManager = NSFileManager.defaultManager;
        [self setupSession];
        // Check for any files that need to be compressed.
        // But don't start right away.
        // Wait for the app startup process to finish.
        
        [self performSelector:@selector(compressNextLogFile) withObject:nil afterDelay:5.0];
        [self performSelector:@selector(uploadOldCompressedLogFiles) withObject:nil afterDelay:5.0];
    }
    return self;
}

- (NSString *)sessionIdentifier
{
    return [self logsDirectory];
}


- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(compressNextLogFile) object:nil];
}

- (void)compressLogFile:(DDLogFileInfo *)logFile
{
    self.isCompressing = YES;

    CompressingAndUploadingLogFileManager* __weak weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [weakSelf backgroundThread_CompressLogFile:logFile];
    });
}

- (void)compressNextLogFile
{
    if (self.isCompressing)
    {
        // We're already compressing a file.
        // Wait until it's done to move onto the next file.
        return;
    }
    
    NSLogVerbose(@"CompressingAndUploadingLogFileManager: compressNextLogFile");
    
    upToDate = NO;
    
    NSArray *sortedLogFileInfos = [self sortedLogFileInfos];
    
    NSUInteger count = [sortedLogFileInfos count];
    if (count == 0)
    {
        // Nothing to compress
        upToDate = YES;
        return;
    }
    
    NSUInteger i = count;
    while (i > 0)
    {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:(i - 1)];
        
        if (logFileInfo.isArchived && !logFileInfo.isCompressed)
        {
            [self compressLogFile:logFileInfo];
            
            break;
        }
        
        i--;
    }
    
    upToDate = YES;
}

-(void)uploadOldCompressedLogFiles{
    
    if(doUpload == NO){
        return;
    }
    
    NSArray *unsortedLogFileInfos = [self unsortedLogFileInfosGZ];
    NSLogVerbose(@"CompressingAndUploadingLogFileManager: unsortedLogFileInfos: %@", unsortedLogFileInfos);
    
    for (DDLogFileInfo *fileInfo in unsortedLogFileInfos) {
        NSLogVerbose(@"CompressingAndUploadingLogFileManager: fileInfo: %@", fileInfo);

        if (fileInfo.isArchived) {
            NSLogVerbose(@"is Archived, uploading...");

            [self uploadArchivedFile:fileInfo];
        }
    }

}

// could swizzle these here I guess
#pragma mark - override DDFilelogger methods to get gz files

- (NSString *)applicationNameGZ {
    static NSString *_appName;
    static dispatch_once_t onceToken;
    NSLogVerbose(@"applicationName");

    dispatch_once(&onceToken, ^{
        _appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        
        if (_appName.length == 0) {
            _appName = [[NSProcessInfo processInfo] processName];
        }
        
        if (_appName.length == 0) {
            _appName = @"";
        }
    });
    
    return _appName;
}

- (BOOL)isLogFileGZ:(NSString *)fileName {
    NSString *appName = [self applicationNameGZ];
    NSLogVerbose(@"isLogFile");

    // We need to add a space to the name as otherwise we could match applications that have the name prefix.
    BOOL hasProperPrefix = [fileName hasPrefix:[appName stringByAppendingString:@" "]];
    BOOL hasProperSuffix = [fileName hasSuffix:@".gz"];
    
    return (hasProperPrefix && hasProperSuffix);
}

- (NSArray *)unsortedLogFileInfosGZ {
    NSArray *unsortedLogFilePaths = [self unsortedLogFilePathsGZ];
    NSLogVerbose(@"CompressingAndUploadingLogFileManager: unsortedLogFilePaths: %@", unsortedLogFilePaths);

    NSMutableArray *unsortedLogFileInfos = [NSMutableArray arrayWithCapacity:[unsortedLogFilePaths count]];
    
    for (NSString *filePath in unsortedLogFilePaths) {
        DDLogFileInfo *logFileInfo = [[DDLogFileInfo alloc] initWithFilePath:filePath];
        
        [unsortedLogFileInfos addObject:logFileInfo];
    }
    
    return unsortedLogFileInfos;
}

- (NSArray *)unsortedLogFilePathsGZ {
    NSString *logsDirectory = [self logsDirectory];
    NSArray *fileNames = [[fileManager contentsOfDirectoryAtPath:logsDirectory error:nil];
    
    NSMutableArray *unsortedLogFilePaths = [NSMutableArray arrayWithCapacity:[fileNames count]];
    
    for (NSString *fileName in fileNames) {
        // Filter out any files that aren't log files. (Just for extra safety)
        
#if TARGET_IPHONE_SIMULATOR
        // This is only used on the iPhone simulator for backward compatibility reason.
        //
        // In case of iPhone simulator there can be 'archived' extension. isLogFile:
        // method knows nothing about it. Thus removing it for this method.
        NSString *theFileName = [fileName stringByReplacingOccurrencesOfString:@".archived"
                                                                    withString:@""];
        
        if ([self isLogFileGZ:theFileName])
#else
            
            if ([self isLogFileGZ:fileName])
#endif
            {
                NSString *filePath = [logsDirectory stringByAppendingPathComponent:fileName];
                
                [unsortedLogFilePaths addObject:filePath];
            }
    }
    
    return unsortedLogFilePaths;
}

#pragma mark - compressionDidSucceed
- (void)compressionDidSucceed:(DDLogFileInfo *)logFile
{
    NSLogVerbose(@"CompressingAndUploadingLogFileManager: compressionDidSucceed: %@", logFile.fileName);
    
    // at this point we want to upload logFile
    if(doUpload == YES){
        [self uploadArchivedFile:logFile];
    }
    self.isCompressing = NO;
    
    [self compressNextLogFile];
}

#pragma mark - compressionDidFail

- (void)compressionDidFail:(DDLogFileInfo *)logFile
{
    NSLogWarn(@"CompressingAndUploadingLogFileManager: compressionDidFail: %@", logFile.fileName);
    
    self.isCompressing = NO;
    
    // We should try the compression again, but after a short delay.
    // 
    // If the compression failed there is probably some filesystem issue,
    // so flooding it with compression attempts is only going to make things worse.
    
    NSTimeInterval delay = (60 * 15); // 15 minutes
    
    [self performSelector:@selector(compressNextLogFile) withObject:nil afterDelay:delay];
}

#pragma mark - didArchiveLogFile

- (void)didArchiveLogFile:(NSString *)logFilePath wasRolled:(BOOL)wasRolled {
    NSLogVerbose(@"CompressingAndUploadingLogFileManager: didArchiveLogFile: %@ wasRolled: %@",
                 [logFilePath lastPathComponent], (wasRolled ? @"YES" : @"NO"));

    // If all other log files have been compressed, then we can get started right away.
    // Otherwise we should just wait for the current compression process to finish.

    if (upToDate)
    {
        [self compressLogFile:[DDLogFileInfo logFileWithPath:logFilePath]];
    }
}

#pragma mark - compress file

- (void)backgroundThread_CompressLogFile:(DDLogFileInfo *)logFile
{
    @autoreleasepool {
    
    NSLogInfo(@"CompressingAndUploadingLogFileManager: Compressing log file: %@", logFile.fileName);
    
    // Steps:
    //  1. Create a new file with the same fileName, but added "gzip" extension
    //  2. Open the new file for writing (output file)
    //  3. Open the given file for reading (input file)
    //  4. Setup zlib for gzip compression
    //  5. Read a chunk of the given file
    //  6. Compress the chunk
    //  7. Write the compressed chunk to the output file
    //  8. Repeat steps 5 - 7 until the input file is exhausted
    //  9. Close input and output file
    // 10. Teardown zlib
    
    
    // STEP 1
    
    NSString *inputFilePath = logFile.filePath;
    
    NSString *tempOutputFilePath = [logFile tempFilePathByAppendingPathExtension:@"gz"];
    
#if TARGET_OS_IPHONE
    // We use the same protection as the original file.  This means that it has the same security characteristics.
    // Also, if the app can run in the background, this means that it gets
    // NSFileProtectionCompleteUntilFirstUserAuthentication so that we can do this compression even with the
    // device locked.  c.f. DDFileLogger.doesAppRunInBackground.
    NSString* protection = logFile.fileAttributes[NSFileProtectionKey];
    NSDictionary* attributes = protection == nil ? nil : @{NSFileProtectionKey: protection};
    [fileManager createFileAtPath:tempOutputFilePath contents:nil attributes:attributes];
#endif
    
    // STEP 2 & 3
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:inputFilePath];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:tempOutputFilePath append:NO];
    
    [inputStream open];
    [outputStream open];
    
    // STEP 4
    
    z_stream strm;
    
    // Zero out the structure before (to be safe) before we start using it
    bzero(&strm, sizeof(strm));
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
    
    // Prepare our variables for steps 5-7
    // 
    // inputDataLength  : Total length of buffer that we will read file data into
    // outputDataLength : Total length of buffer that zlib will output compressed bytes into
    // 
    // Note: The output buffer can be smaller than the input buffer because the
    //       compressed/output data is smaller than the file/input data (obviously).
    // 
    // inputDataSize : The number of bytes in the input buffer that have valid data to be compressed.
    // 
    // Imagine compressing a tiny file that is actually smaller than our inputDataLength.
    // In this case only a portion of the input buffer would have valid file data.
    // The inputDataSize helps represent the portion of the buffer that is valid.
    // 
    // Imagine compressing a huge file, but consider what happens when we get to the very end of the file.
    // The last read will likely only fill a portion of the input buffer.
    // The inputDataSize helps represent the portion of the buffer that is valid.
    
    NSUInteger inputDataLength  = (1024 * 2);  // 2 KB
    NSUInteger outputDataLength = (1024 * 1);  // 1 KB
    
    NSMutableData *inputData = [NSMutableData dataWithLength:inputDataLength];
    NSMutableData *outputData = [NSMutableData dataWithLength:outputDataLength];
    
    NSUInteger inputDataSize = 0;
    
    BOOL done = YES;
    NSError* error = nil;
    do
    {
        @autoreleasepool {
        
        // STEP 5
        // Read data from the input stream into our input buffer.
        // 
        // inputBuffer : pointer to where we want the input stream to copy bytes into
        // inputBufferLength : max number of bytes the input stream should read
        // 
        // Recall that inputDataSize is the number of valid bytes that already exist in the
        // input buffer that still need to be compressed.
        // This value is usually zero, but may be larger if a previous iteration of the loop
        // was unable to compress all the bytes in the input buffer.
        // 
        // For example, imagine that we ready 2K worth of data from the file in the last loop iteration,
        // but when we asked zlib to compress it all, zlib was only able to compress 1.5K of it.
        // We would still have 0.5K leftover that still needs to be compressed.
        // We want to make sure not to skip this important data.
        // 
        // The [inputData mutableBytes] gives us a pointer to the beginning of the underlying buffer.
        // When we add inputDataSize we get to the proper offset within the buffer
        // at which our input stream can start copying bytes into without overwriting anything it shouldn't.
        
        const void *inputBuffer = [inputData mutableBytes] + inputDataSize;
        NSUInteger inputBufferLength = inputDataLength - inputDataSize;
        
        NSInteger readLength = [inputStream read:(uint8_t *)inputBuffer maxLength:inputBufferLength];
        if (readLength < 0) {
            error = [inputStream streamError];
            break;
        }
        
        NSLogVerbose(@"CompressingAndUploadingLogFileManager: Read %li bytes from file", (long)readLength);
        
        inputDataSize += readLength;
        
        // STEP 6
        // Ask zlib to compress our input buffer.
        // Tell it to put the compressed bytes into our output buffer.
        
        strm.next_in = (Bytef *)[inputData mutableBytes];   // Read from input buffer
        strm.avail_in = (uInt)inputDataSize;                // as much as was read from file (plus leftovers).
        
        strm.next_out = (Bytef *)[outputData mutableBytes]; // Write data to output buffer
        strm.avail_out = (uInt)outputDataLength;            // as much space as is available in the buffer.
        
        // When we tell zlib to compress our data,
        // it won't directly tell us how much data was processed.
        // Instead it keeps a running total of the number of bytes it has processed.
        // In other words, every iteration from the loop it increments its total values.
        // So to figure out how much data was processed in this iteration,
        // we fetch the totals before we ask it to compress data,
        // and then afterwards we subtract from the new totals.
        
        NSInteger prevTotalIn = strm.total_in;
        NSInteger prevTotalOut = strm.total_out;
        
        int flush = [inputStream hasBytesAvailable] ? Z_SYNC_FLUSH : Z_FINISH;
        deflate(&strm, flush);
        
        NSInteger inputProcessed = strm.total_in - prevTotalIn;
        NSInteger outputProcessed = strm.total_out - prevTotalOut;
        
        NSLogVerbose(@"CompressingAndUploadingLogFileManager: Total bytes uncompressed: %lu", (unsigned long)strm.total_in);
        NSLogVerbose(@"CompressingAndUploadingLogFileManager: Total bytes compressed: %lu", (unsigned long)strm.total_out);
        NSLogVerbose(@"CompressingAndUploadingLogFileManager: Compression ratio: %.1f%%",
                     (1.0F - (float)(strm.total_out) / (float)(strm.total_in)) * 100);
        
        // STEP 7
        // Now write all compressed bytes to our output stream.
        // 
        // It is theoretically possible that the write operation doesn't write everything we ask it to.
        // Although this is highly unlikely, we take precautions.
        // Also, we watch out for any errors (maybe the disk is full).
        
        NSInteger totalWriteLength = 0;
        NSInteger writeLength = 0;
        
        do
        {
            const void *outputBuffer = [outputData mutableBytes] + totalWriteLength;
            NSUInteger outputBufferLength = outputProcessed - totalWriteLength;
            
            writeLength = [outputStream write:(const uint8_t *)outputBuffer maxLength:outputBufferLength];
            
            if (writeLength < 0)
            {
                error = [outputStream streamError];
            }
            else
            {
                totalWriteLength += writeLength;
            }
            
        } while((totalWriteLength < outputProcessed) && !error);
        
        // STEP 7.5
        // 
        // We now have data in our input buffer that has already been compressed.
        // We want to remove all the processed data from the input buffer,
        // and we want to move any unprocessed data to the beginning of the buffer.
        // 
        // If the amount processed is less than the valid buffer size, we have leftovers.
        
        NSUInteger inputRemaining = inputDataSize - inputProcessed;
        if (inputRemaining > 0)
        {
            void *inputDst = [inputData mutableBytes];
            void *inputSrc = [inputData mutableBytes] + inputProcessed;
            
            memmove(inputDst, inputSrc, inputRemaining);
        }
        
        inputDataSize = inputRemaining;
        
        // Are we done yet?
        
        done = ((flush == Z_FINISH) && (inputDataSize == 0));
        
        // STEP 8
        // Loop repeats until end of data (or unlikely error)
        
        } // end @autoreleasepool
        
    } while (!done && error == nil);
    
    // STEP 9
    
    [inputStream close];
    [outputStream close];
    
    // STEP 10
    
    deflateEnd(&strm);
    
    // We're done!
    // Report success or failure back to the logging thread/queue.
    
    if (error)
    {
        // Remove output file.
        // Our compression attempt failed.

        NSLogError(@"Compression of %@ failed: %@", inputFilePath, error);
        error = nil;
        BOOL ok = [fileManager removeItemAtPath:tempOutputFilePath error:&error];
        if (!ok)
            NSLogError(@"Failed to clean up %@ after failed compression: %@", tempOutputFilePath, error);
        
        // Report failure to class via logging thread/queue
        
        dispatch_async([DDLog loggingQueue], ^{ @autoreleasepool {
            
            [self compressionDidFail:logFile];
        }});
    }
    else
    {
        // Remove original input file.
        // It will be replaced with the new compressed version.

        error = nil;
        BOOL ok = [fileManager removeItemAtPath:inputFilePath error:&error];
        if (!ok)
            NSLogWarn(@"Warning: failed to remove original file %@ after compression: %@", inputFilePath, error);
        
        // Mark the compressed file as archived,
        // and then move it into its final destination.
        // 
        // temp-log-ABC123.txt.gz -> log-ABC123.txt.gz
        // 
        // The reason we were using the "temp-" prefix was so the file would not be
        // considered a log file while it was only partially complete.
        // Only files that begin with "log-" are considered log files.
        
        DDLogFileInfo *compressedLogFile = [DDLogFileInfo logFileWithPath:tempOutputFilePath];
        compressedLogFile.isArchived = YES;
        
        NSString *outputFileName = [logFile fileNameByAppendingPathExtension:@"gz"];
        [compressedLogFile renameFile:outputFileName];
        
        // Report success to class via logging thread/queue
        
        dispatch_async([DDLog loggingQueue], ^{ @autoreleasepool {
            
            [self compressionDidSucceed:compressedLogFile];
        }});
    }
    
    } // end @autoreleasepool
}

#pragma mark - upload files

// retries any files that may have errored
- (void)uploadArchivedFile:(DDLogFileInfo *)logFile
{
    NSLogVerbose(@"CompressingAndUploadingLogFileManager uploadArchivedFile: %@", logFile.filePath);
    
    dispatch_async([DDLog loggingQueue], ^{
        [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            dispatch_async([DDLog loggingQueue], ^{ @autoreleasepool {
                NSMutableSet *filesToUpload = [NSMutableSet setWithCapacity:1];
                
                [filesToUpload addObject:logFile.filePath];
                
                // check we are not already uploading it
                for (NSURLSessionTask *task in uploadTasks) {
                    NSLogVerbose(@"removinguploadTasks : %@", [self filePathForTask:task]);

                    [filesToUpload removeObject:[self filePathForTask:task]];
                }
                
                for (NSString *filePath in filesToUpload) {
                    NSLogVerbose(@"filePath : %@", filePath);
                    if ([self->fileManager fileExistsAtPath:filePath]) {
                        NSLogVerbose(@"filePath exists : %@", filePath);
                        if ([self->fileManager isReadableFileAtPath:filePath]) {
                            NSLogVerbose(@"filePath isReadable : %@", filePath);
                            [self uploadLogFile:filePath];
                        } else {
                            NSAssert(NO, @"file that came from log file infos should be readable");
                        }
                    }
                    else{
                        NSLogVerbose(@"filePath does not exist at path : %@", filePath);
                    }
                }
            }});
        }];
    });
}


- (void)uploadLogFile:(NSString *)logFilePath
{
    NSMutableURLRequest *request = [self.uploadRequest mutableCopy];
    [request setValue:[logFilePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] forHTTPHeaderField:@"X-BackgroundUpload-File"];
    // added extra header to identify upload
    [request setValue:[UIDevice.currentDevice.identifierForVendor.UUIDString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] forHTTPHeaderField:@"X-BackgroundUpload-File-UUID"];
    
    NSURLSessionTask *task = [self.session uploadTaskWithRequest:request fromFile:[NSURL fileURLWithPath:logFilePath]];
    NSLogVerbose(@"CompressingAndUploadingLogFileManager: started uploading: %@", [self filePathForTask:task]); // test decoding header
    task.taskDescription = logFilePath;
    [task resume];
    if ([self.delegate respondsToSelector:@selector(attemptingUploadForFilePath:)]) {
        [self.delegate attemptingUploadForFilePath:logFilePath];
    }
}

- (NSString *)filePathForTask:(NSURLSessionTask *)task
{
    // internets seem to suggest taskDescription is persisted, but in practice we see it coming back nil sometimes:
    // http://stackoverflow.com/questions/24500545/checking-which-kind-of-nsurlsessiontask-occurred
    if (task.taskDescription) {
        return task.taskDescription;
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSString *value = [[task.currentRequest valueForHTTPHeaderField:@"X-BackgroundUpload-File"] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        #pragma clang diagnostic pop
        NSAssert(value, @"header must contain file path for task %@", task);
        return value;
    }
}

- (void)setupSession
{
    void (^block)(void) = ^{
        NSURLSessionConfiguration *backgroundConfiguration;
        // no need for guard as targeting iOS 8 now.
        backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[self sessionIdentifier]];
        backgroundConfiguration.discretionary = self.discretionary;
        // add timeouts otherwise it never seems to fail
        backgroundConfiguration.timeoutIntervalForRequest = 10.0;
        backgroundConfiguration.timeoutIntervalForResource = 20.0;
        self.session = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:self delegateQueue:nil];
        
    };
    
    // on nsurlsessiond crashes, sessionWithConfiguration can block for a long time,
    // but from the background make sure we set up synhronously in didFinishLaunchingWithOptions
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        dispatch_sync([DDLog loggingQueue], block);
    } else {
        dispatch_async([DDLog loggingQueue], block);
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLogVerbose(@"URLSessionDidFinishEventsForBackgroundURLSession: session: %@", session);

    // ensure all deletes are complete before calling completion
    dispatch_async([DDLog loggingQueue], ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler();
                self.completionHandler = nil;
            }
        });
    });
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLogVerbose(@"CompressingAndUploadingLogFileManager: session: %@ didBecomeInvalidWithError: %@", session, error.localizedDescription);
    [self setupSession];
}

#pragma mark - app delegate forwarding

- (void)handleEventsForBackgroundURLSession:(void (^)(void))completionHandler
{
    NSLogVerbose(@"handleEventsForBackgroundURLSession");

    self.completionHandler = completionHandler;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLogVerbose(@"CompressingAndUploadingLogFileManager: didCompleteWithError");
    
    [self uploadFilePath:[self filePathForTask:task] didCompleteWithError:error];
}

- (void)uploadFilePath:(NSString *)filePath didCompleteWithError:(NSError *)error
{
    NSLogVerbose(@"CompressingAndUploadingLogFileManager: upload: %@ didCompleteWithError: %@", filePath, error);
    
    dispatch_async([DDLog loggingQueue], ^{ @autoreleasepool {
        if (!error) {
            NSError *deleteError;
            [fileManager removeItemAtPath:filePath error:&deleteError];
            if (deleteError) {
                NSLogError(@"CompressingAndUploadingLogFileManager: Error deleting file %@: %@", filePath, deleteError);
            }
            else{
                 NSLogVerbose(@"CompressingAndUploadingLogFileManager: deleted file %@:", filePath);
            }
            if ([self.delegate respondsToSelector:@selector(uploadTaskForFilePath:didCompleteWithError:)]) {
                [self.delegate uploadTaskForFilePath:filePath didCompleteWithError:nil];
            }
        } else if ([self.delegate respondsToSelector:@selector(uploadTaskForFilePath:didCompleteWithError:)]) {
            NSArray *filePaths = [self sortedLogFilePaths];
            NSUInteger i = [filePaths indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [filePath isEqualToString:obj];
            }];
            
            // only call back with failure if this was the last retry
            if (i == NSNotFound || i >= self.maximumNumberOfLogFiles - 1) {
                [self.delegate uploadTaskForFilePath:filePath didCompleteWithError:error];
            }
        }
    }});
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation DDLogFileInfo (Compressor)

@dynamic isCompressed;

- (BOOL)isCompressed
{
    return [[[self fileName] pathExtension] isEqualToString:@"gz"];
}

- (NSString *)tempFilePathByAppendingPathExtension:(NSString *)newExt
{
    // Example:
    // 
    // Current File Name: "/full/path/to/log-ABC123.txt"
    // 
    // newExt: "gzip"
    // result: "/full/path/to/temp-log-ABC123.txt.gzip"
    
    NSString *tempFileName = [NSString stringWithFormat:@"temp-%@", [self fileName]];
    
    NSString *newFileName = [tempFileName stringByAppendingPathExtension:newExt];
    
    NSString *fileDir = [[self filePath] stringByDeletingLastPathComponent];
    
    NSString *newFilePath = [fileDir stringByAppendingPathComponent:newFileName];
    
    return newFilePath;
}

- (NSString *)fileNameByAppendingPathExtension:(NSString *)newExt
{
    // Example:
    // 
    // Current File Name: "log-ABC123.txt"
    // 
    // newExt: "gzip"
    // result: "log-ABC123.txt.gzip"
    
    NSString *fileNameExtension = [[self fileName] pathExtension];
    
    if ([fileNameExtension isEqualToString:newExt])
    {
        return [self fileName];
    }
    
    return [[self fileName] stringByAppendingPathExtension:newExt];
}



@end
