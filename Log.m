#import <Foundation/Foundation.h>
#import "Log.h"
#import <unistd.h>

static NSString* progressName = nil;

#define INVALID_FD -1

// 等级描述信息
 

// 原始的stdErr文件描述符
static int _logFileFD = INVALID_FD;

// 是否写到文件
static BOOL _isWriteToFile = NO;

NSString* _logConfigFilePath = nil;


static int _logLevel = LOG_INFO | LOG_WARNING | LOG_ERROR; 

NSString* nowTime()
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    
    return [NSString stringWithFormat:@"%.2d-%.2d %.2d:%.2d:%.2d",(int)[comps month],(int)[comps day],(int)[comps hour],(int)[comps minute],(int)[comps second]];
}



void openLogFile(NSString* logFilePath)
{
    if (_logFileFD != INVALID_FD)
    {
        close(_logFileFD);
    }
    
    _logFileFD = open([logFilePath UTF8String], O_RDWR | O_CREAT | O_APPEND, S_IRWXU | S_IRWXG | S_IRWXO);
    if (_logFileFD <= 0)
    {
        perror("open logfile fail!!");
    }
    

}

// 实际的日志输出操作
#define doLog(format,levelInfo)\
{\
    if (progressName == nil)\
    {\
        progressName = [[NSProcessInfo processInfo] processName];\
    }\
    NSMutableString* newFormat = [NSMutableString stringWithFormat:@"%@ %@<%@>%@\n", nowTime(), progressName,(levelInfo), (format)];\
    const char* str = [newFormat UTF8String];\
    size_t len = strlen(str);\
    write(STDERR_FILENO, str, len);\
    if (_isWriteToFile && _logFileFD != INVALID_FD)\
    {\
        write(_logFileFD, str, len);\
    }\
}

#ifdef ENABLE_LOG

#define logFuncImp(funcName, funcDes, fiterKeyName)\
void _##funcName(NSString* format)\
{\
    if(_logLevel & fiterKeyName)\
    {\
        doLog(format, funcDes);\
    }\
}

logFuncImp(logInfo, @"Info", LOG_INFO)
logFuncImp(logWarning, @"Warning", LOG_WARNING)
logFuncImp(logError, @"Error", LOG_ERROR)

#endif

void setLogLevel(LogLevel level)
{
    _logLevel = level;
}

void setLogFilePath(NSString* filePath)
{
    if (filePath != nil)
    {
        NSMutableDictionary* configDic = [NSMutableDictionary dictionaryWithContentsOfFile:_logConfigFilePath];
        [configDic setObject:filePath forKey:LOG_FILE_PATH_NAME];
        [configDic writeToFile:_logConfigFilePath atomically:YES];
        
        openLogFile(filePath);
    }
}

// 设置日志配置文件路径
void logReadConfig(NSString* logConfigFilePath)
{
    NSDictionary* configDic = [NSDictionary dictionaryWithContentsOfFile:logConfigFilePath];
    if(configDic != nil)
    {
        [_logConfigFilePath release];
        _logConfigFilePath = [logConfigFilePath copy];
        _logLevel = 0;
        
        // 判断logInfo是否打开
        NSString* levelInfo = [configDic objectForKey:LOG_INFO_NAME];
        if([levelInfo isEqualToString:@"YES"])
        {
            _logLevel |= LOG_INFO;
        }
        
        // 判断logWarning是否打开
        levelInfo = [configDic objectForKey:LOG_WARNING_NAME];
        if([levelInfo isEqualToString:@"YES"])
        {
            _logLevel |= LOG_WARNING;
        }
        
        // 判断logError是否打开
        levelInfo = [configDic objectForKey:LOG_ERROR_NAME];
        if([levelInfo isEqualToString:@"YES"])
        {
            _logLevel |= LOG_ERROR;
        }
        
        // 获取是否写日志到文件和日志文件路径
        NSString* logFilePath = [configDic objectForKey:LOG_FILE_PATH_NAME];
        NSString* isWriteToFile = [configDic objectForKey:LOG_WRITE_TO_FILE_NAME];
        
        // 如果写日志到文件，重定向log输出
        if([isWriteToFile isEqualToString:@"YES"])
        {
            _isWriteToFile = YES;
            openLogFile(logFilePath);
        }
    }
}
