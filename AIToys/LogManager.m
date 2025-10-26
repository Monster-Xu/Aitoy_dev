//
//  LogManager.m
//  自动日志管理器实现
//

#import "LogManager.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <sys/utsname.h>

@interface LogManager ()

@property (nonatomic, strong) NSString *logFilePath;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) dispatch_queue_t logQueue;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL isAutoLogging;

@end

@implementation LogManager

+ (void)startAutoLogging {
    LogManager *manager = [self sharedManager];
    if (!manager.isAutoLogging) {
        manager.isAutoLogging = YES;
        [manager setupAutoLogging];
        [manager logInfo:@"========== 自动日志记录已启动 =========="];
    }
}

+ (instancetype)sharedManager {
    static LogManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupLogSystem];
    }
    return self;
}

- (void)setupLogSystem {
    _logQueue = dispatch_queue_create("com.app.logQueue", DISPATCH_QUEUE_SERIAL);
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [_dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *logDirectory = [documentPath stringByAppendingPathComponent:@"Logs"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *fileDateFormatter = [[NSDateFormatter alloc] init];
    [fileDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [fileDateFormatter stringFromDate:[NSDate date]];
    
    _logFilePath = [logDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"app_log_%@.txt", dateString]];
    
    if (![fileManager fileExistsAtPath:_logFilePath]) {
        [fileManager createFileAtPath:_logFilePath contents:nil attributes:nil];
    }
    
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_logFilePath];
    [_fileHandle seekToEndOfFile];
    
    [self setupCrashHandler];
}

#pragma mark - 自动日志记录

- (void)setupAutoLogging {
    // 1. Hook UIViewController 生命周期
    [self hookViewControllerLifecycle];
    
    // 2. Hook UIControl 事件
    [self hookUIControlEvents];
    
    // 3. Hook 网络请求（NSURLSession）
    [self hookNetworkRequests];
    
    // 4. 监听应用生命周期
    [self observeAppLifecycle];
    
    // 5. 监听通知
    [self observeNotifications];
}

#pragma mark - Hook ViewController

- (void)hookViewControllerLifecycle {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [UIViewController class];
        
        [self swizzleMethod:@selector(viewDidLoad)
                  withClass:class
                 newSelector:@selector(log_viewDidLoad)];
        
        [self swizzleMethod:@selector(viewWillAppear:)
                  withClass:class
                 newSelector:@selector(log_viewWillAppear:)];
        
        [self swizzleMethod:@selector(viewDidAppear:)
                  withClass:class
                 newSelector:@selector(log_viewDidAppear:)];
        
        [self swizzleMethod:@selector(viewWillDisappear:)
                  withClass:class
                 newSelector:@selector(log_viewWillDisappear:)];
    });
}

#pragma mark - Hook UIControl

- (void)hookUIControlEvents {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [UIControl class];
        
        [self swizzleMethod:@selector(sendAction:to:forEvent:)
                  withClass:class
                 newSelector:@selector(log_sendAction:to:forEvent:)];
    });
}

#pragma mark - Hook 网络请求

- (void)hookNetworkRequests {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [NSURLSessionTask class];
        
        [self swizzleMethod:@selector(resume)
                  withClass:class
                 newSelector:@selector(log_resume)];
    });
}

#pragma mark - 应用生命周期

- (void)observeAppLifecycle {
    // 应用启动
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    // 进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    // 进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // 即将终止
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    // 内存警告
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

#pragma mark - 通知监听

- (void)observeNotifications {
    // 键盘显示
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

#pragma mark - 应用生命周期回调

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSDictionary *info = @{
        @"version": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"unknown",
        @"build": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ?: @"unknown",
        @"system": [[UIDevice currentDevice] systemVersion],
        @"device": [self getDeviceModel]
    };
    [self logUserAction:@"应用启动" params:info];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self logInfo:@"应用进入前台"];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self logInfo:@"应用进入后台"];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self logInfo:@"应用即将终止"];
}

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)notification {
    [self logWarning:@"收到内存警告"];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self logDebug:@"键盘将要显示"];
}

#pragma mark - Method Swizzling

- (void)swizzleMethod:(SEL)originalSelector withClass:(Class)class newSelector:(SEL)newSelector {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, newSelector);
    
    if (!originalMethod || !swizzledMethod) {
        return;
    }
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                           newSelector,
                           method_getImplementation(originalMethod),
                           method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - 崩溃处理

- (void)setupCrashHandler {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

void uncaughtExceptionHandler(NSException *exception) {
    NSString *crashLog = [NSString stringWithFormat:@"\n========== 崩溃日志 ==========\n时间: %@\n异常名称: %@\n异常原因: %@\n堆栈信息:\n%@\n==========================\n",
                         [[LogManager sharedManager].dateFormatter stringFromDate:[NSDate date]],
                         exception.name,
                         exception.reason,
                         [exception.callStackSymbols componentsJoinedByString:@"\n"]];
    
    [[LogManager sharedManager] writeLogToFile:crashLog];
    [[LogManager sharedManager].fileHandle synchronizeFile];
}

#pragma mark - 日志记录方法

- (void)logWithLevel:(LogLevel)level message:(NSString *)message {
    NSString *levelString = [self stringForLogLevel:level];
    NSString *timestamp = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *logMessage = [NSString stringWithFormat:@"[%@] [%@] %@\n", timestamp, levelString, message];
    
    [self writeLogToFile:logMessage];
    
    #ifdef DEBUG
    NSLog(@"%@", logMessage);
    #endif
}

- (void)logDebug:(NSString *)message {
    [self logWithLevel:LogLevelDebug message:message];
}

- (void)logInfo:(NSString *)message {
    [self logWithLevel:LogLevelInfo message:message];
}

- (void)logWarning:(NSString *)message {
    [self logWithLevel:LogLevelWarning message:message];
}

- (void)logError:(NSString *)message {
    [self logWithLevel:LogLevelError message:message];
}

- (void)logUserAction:(NSString *)action params:(NSDictionary *)params {
    NSString *paramsString = @"";
    if (params && params.count > 0) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        if (jsonData) {
            paramsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    
    NSString *message = [NSString stringWithFormat:@"用户操作: %@ | 参数: %@", action, paramsString];
    [self logWithLevel:LogLevelInfo message:message];
}

#pragma mark - 文件操作

- (void)writeLogToFile:(NSString *)log {
    dispatch_async(self.logQueue, ^{
        @try {
            NSData *data = [log dataUsingEncoding:NSUTF8StringEncoding];
            if (data && self.fileHandle) {
                [self.fileHandle writeData:data];
            }
        } @catch (NSException *exception) {
            NSLog(@"写入日志失败: %@", exception);
        }
    });
}

- (void)exportLogsWithCompletion:(void (^)(NSURL * _Nullable, NSError * _Nullable))completion {
    dispatch_async(self.logQueue, ^{
        @try {
            [self.fileHandle synchronizeFile];
            
            NSString *logDirectory = [self.logFilePath stringByDeletingLastPathComponent];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:logDirectory error:nil];
            
            // 导出到 Documents 目录（可在"文件"app 中访问）
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *exportDirectory = [documentsPath stringByAppendingPathComponent:@"ExportedLogs"];
            
            // 创建导出目录
            if (![fileManager fileExistsAtPath:exportDirectory]) {
                [fileManager createDirectoryAtPath:exportDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            // 生成导出文件名
            NSDateFormatter *exportFormatter = [[NSDateFormatter alloc] init];
            [exportFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
            NSString *exportFileName = [NSString stringWithFormat:@"AppLogs_%@.txt", [exportFormatter stringFromDate:[NSDate date]]];
            NSString *exportPath = [exportDirectory stringByAppendingPathComponent:exportFileName];
            
            // 合并所有日志文件
            NSMutableString *allLogs = [NSMutableString string];
            [allLogs appendString:@"========== 应用日志导出 ==========\n"];
            [allLogs appendFormat:@"导出时间: %@\n", [self.dateFormatter stringFromDate:[NSDate date]]];
            [allLogs appendFormat:@"应用版本: %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
            [allLogs appendFormat:@"系统版本: %@\n", [[UIDevice currentDevice] systemVersion]];
            [allLogs appendFormat:@"设备型号: %@\n\n", [self getDeviceModel]];
            
            // 按日期排序日志文件
            NSArray *sortedLogFiles = [logFiles sortedArrayUsingComparator:^NSComparisonResult(NSString *file1, NSString *file2) {
                return [file1 compare:file2];
            }];
            
            for (NSString *fileName in sortedLogFiles) {
                if ([fileName hasPrefix:@"app_log_"]) {
                    NSString *filePath = [logDirectory stringByAppendingPathComponent:fileName];
                    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                    if (content) {
                        [allLogs appendFormat:@"\n========== %@ ==========\n", fileName];
                        [allLogs appendString:content];
                    }
                }
            }
            
            // 写入导出文件
            NSError *writeError = nil;
            [allLogs writeToFile:exportPath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (writeError) {
                    if (completion) completion(nil, writeError);
                } else {
                    NSURL *fileURL = [NSURL fileURLWithPath:exportPath];
                    if (completion) completion(fileURL, nil);
                }
            });
            
        } @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"LogManagerError" code:-1 userInfo:@{NSLocalizedDescriptionKey: exception.reason}];
                if (completion) completion(nil, error);
            });
        }
    });
}

- (void)clearLogs {
    dispatch_async(self.logQueue, ^{
        [self.fileHandle synchronizeFile];
        
        NSString *logDirectory = [self.logFilePath stringByDeletingLastPathComponent];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:logDirectory error:nil];
        
        for (NSString *fileName in logFiles) {
            if ([fileName hasPrefix:@"app_log_"]) {
                NSString *filePath = [logDirectory stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:filePath error:nil];
            }
        }
        
        // 重新创建文件（不需要 error 参数）
        [fileManager createFileAtPath:self.logFilePath contents:nil attributes:nil];
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logFilePath];
        [self.fileHandle seekToEndOfFile];
    });
}

- (NSString *)getLogFileSize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *logDirectory = [self.logFilePath stringByDeletingLastPathComponent];
    NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:logDirectory error:nil];
    
    unsigned long long totalSize = 0;
    for (NSString *fileName in logFiles) {
        if ([fileName hasPrefix:@"app_log_"]) {
            NSString *filePath = [logDirectory stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
            totalSize += [attrs fileSize];
        }
    }
    
    return [self formatFileSize:totalSize];
}

#pragma mark - 辅助方法

- (NSString *)stringForLogLevel:(LogLevel)level {
    switch (level) {
        case LogLevelDebug:   return @"DEBUG";
        case LogLevelInfo:    return @"INFO";
        case LogLevelWarning: return @"WARNING";
        case LogLevelError:   return @"ERROR";
        default:              return @"UNKNOWN";
    }
}

- (NSString *)formatFileSize:(unsigned long long)size {
    if (size < 1024) {
        return [NSString stringWithFormat:@"%llu B", size];
    } else if (size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2f KB", size / 1024.0];
    } else {
        return [NSString stringWithFormat:@"%.2f MB", size / (1024.0 * 1024.0)];
    }
}

- (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void)dealloc {
    [_fileHandle closeFile];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

#pragma mark - UIViewController Category

@implementation UIViewController (AutoLogging)

- (void)log_viewDidLoad {
    [self log_viewDidLoad];
    [[LogManager sharedManager] logInfo:[NSString stringWithFormat:@"页面加载: %@", NSStringFromClass([self class])]];
}

- (void)log_viewWillAppear:(BOOL)animated {
    [self log_viewWillAppear:animated];
    [[LogManager sharedManager] logInfo:[NSString stringWithFormat:@"页面将显示: %@", NSStringFromClass([self class])]];
}

- (void)log_viewDidAppear:(BOOL)animated {
    [self log_viewDidAppear:animated];
    [[LogManager sharedManager] logInfo:[NSString stringWithFormat:@"页面已显示: %@", NSStringFromClass([self class])]];
}

- (void)log_viewWillDisappear:(BOOL)animated {
    [self log_viewWillDisappear:animated];
    [[LogManager sharedManager] logInfo:[NSString stringWithFormat:@"页面将消失: %@", NSStringFromClass([self class])]];
}

@end

#pragma mark - UIControl Category

@implementation UIControl (AutoLogging)

- (void)log_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [self log_sendAction:action to:target forEvent:event];
    
    NSString *controlType = NSStringFromClass([self class]);
    NSString *actionName = NSStringFromSelector(action);
    NSString *targetName = target ? NSStringFromClass([target class]) : @"nil";
    
    NSString *title = @"";
    if ([self isKindOfClass:[UIButton class]]) {
        title = [(UIButton *)self currentTitle] ?: @"";
    }
    
    NSDictionary *params = @{
        @"控件类型": controlType,
        @"动作": actionName,
        @"目标": targetName,
        @"标题": title
    };
    
    [[LogManager sharedManager] logUserAction:@"控件点击" params:params];
}

@end

#pragma mark - NSURLSessionTask Category

@implementation NSURLSessionTask (AutoLogging)

- (void)log_resume {
    [self log_resume];
    
    if (self.currentRequest) {
        NSString *url = self.currentRequest.URL.absoluteString;
        NSString *method = self.currentRequest.HTTPMethod;
        
        [[LogManager sharedManager] logInfo:[NSString stringWithFormat:@"网络请求: %@ %@", method, url]];
        
        // 监听请求完成
        [self addObserver:[LogManager sharedManager]
               forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
}

@end

@implementation LogManager (KVO)

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([object isKindOfClass:[NSURLSessionTask class]]) {
        NSURLSessionTask *task = (NSURLSessionTask *)object;
        
        if (task.state == NSURLSessionTaskStateCompleted) {
            [task removeObserver:self forKeyPath:@"state"];
            
            if (task.error) {
                [[LogManager sharedManager] logError:[NSString stringWithFormat:@"网络请求失败: %@ - %@",
                                                     task.currentRequest.URL.absoluteString,
                                                     task.error.localizedDescription]];
            } else if ([task isKindOfClass:[NSURLSessionDataTask class]]) {
                [[LogManager sharedManager] logInfo:[NSString stringWithFormat:@"网络请求成功: %@",
                                                    task.currentRequest.URL.absoluteString]];
            }
        }
    }
}

@end
