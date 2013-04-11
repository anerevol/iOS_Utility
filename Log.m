
#import <Foundation/Foundation.h>
#import "Log.h"
#import <unistd.h>

// 在设置词典中的键名
#define LOG_INFO_NAME @"LogLevelInfo"
#define LOG_WARNING_NAME @"LogLevelWarning"
#define LOG_ERROR_NAME @"LogLevelError"
#define LOG_FILE_PATH_NAME @"LogFilePath"
#define LOG_WRITE_TO_FILE_NAME @"LogWriteToFile"


#define INVALID_FD -1

// 等级描述信息
 

// 原始的stdErr文件描述符
static int _rawStdErrFD = INVALID_FD;

// 是否写到文件
static BOOL _isWriteToFile = NO;

NSString* _logConfigFilePath = nil;

enum _IFlyLogLevel
{
    LOG_INFO = 1,
    LOG_WARNING = 2,
    LOG_ERROR = 4
};

static int _logLevel = LOG_INFO | LOG_WARNING | LOG_ERROR; 

typedef enum _IFlyLogLevel IFlyLogLevel;

// 重定向stdErr到指定路径
static void redirectLogInfo(NSString* logFilePath)
{
    FILE* logFile = fopen([logFilePath UTF8String], "a+");
    if(logFile != NULL)
    {
        fclose(logFile);
        if(_rawStdErrFD == INVALID_FD)
        {
            _rawStdErrFD = dup(STDERR_FILENO);
        }
        freopen([logFilePath UTF8String], "a+", stderr);
    }
}

// 恢复stdErr的重定向
static void resumeLogInfo()
{
    fflush(stderr);
    if(_rawStdErrFD != INVALID_FD)
    {   
         dup2(_rawStdErrFD, STDERR_FILENO);
    }
}

// 实际的日志输出操作
#define _DO_LOG(format,levelInfo)\
{\
    va_list arg_prt;\
    NSMutableString* newFormat = [NSMutableString stringWithFormat:@"<%@>:%@", (levelInfo), (format)];\
    va_start(arg_prt, format);\
    NSLogv(newFormat, arg_prt);\
    va_end(arg_prt);\
}

#ifdef ENABLE_LOG
void _LogInfo(NSString* format, ...)
{
    if(_logLevel & LOG_INFO)
    {
        _DO_LOG(format, @"Info");
    }
}

void _LogWarning(NSString* format, ...)
{
    if(_logLevel & LOG_WARNING)
    {
        _DO_LOG(format, @"Warning");
    }
}

void _LogError(NSString* format, ...)
{
    if(_logLevel & LOG_ERROR)
    {
        _DO_LOG(format, @"Error");
    }

}
#endif


// 设置日志配置文件路径    
void LogReadConfig(NSString* logConfigFilePath)
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
            redirectLogInfo(logFilePath);
        }
        
    }
}

// 设置日志文件路径
static void setLogFilePath(NSString* logFilePath)
{
    if(logFilePath != NULL)
    {
        NSMutableDictionary* configDic = [NSMutableDictionary dictionaryWithContentsOfFile:_logConfigFilePath];
        [configDic setObject:logFilePath forKey:LOG_FILE_PATH_NAME];
        
        if(_isWriteToFile)
        {
            redirectLogInfo(logFilePath);
        }
    }
}