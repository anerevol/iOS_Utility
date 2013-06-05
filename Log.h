
@class NSString;


// 在设置词典中的键名
#define LOG_MASS_NAME @"LogLevelInfo"
#define LOG_INFO_NAME @"LogLevelInfo"
#define LOG_WARNING_NAME @"LogLevelWarning"
#define LOG_ERROR_NAME @"LogLevelError"
#define LOG_FILE_PATH_NAME @"LogFilePath"
#define LOG_WRITE_TO_FILE_NAME @"LogWriteToFile"

#ifdef __cplusplus
extern "C" {
#endif
    
#define ENABLE_LOG 1
#ifdef ENABLE_LOG
 
// 这里用宏的目的是将调用函数的函数名以及调用的行号打印出来 
#define createLogFunc(name, format, arg...)\
void _##name(NSString*);\
{\
    NSString* newFormat = [NSString stringWithFormat:@"[func:%s,line:%d]:%@%@", __func__, __LINE__, @"%@", format];\
    newFormat = [NSString stringWithFormat:newFormat, @"", ##arg];\
    _##name(newFormat);\
}
   
// 普通描述信息
#define logMass(format, arg...) createLogFunc(logMass, format, ##arg)
    
// 普通描述信息
#define logInfo(format, arg...) createLogFunc(logInfo, format, ##arg)
    
// 警告信息
#define logWarning(format, arg...) createLogFunc(logWarning, format, ##arg)
    
// 错误信息
#define logError(format, arg...) createLogFunc(logError, format, ##arg)


// 设置日志配置文件路径    
void logReadConfig(NSString* logConfigFilePath);
    
typedef enum
{
    LOG_MASS = 1,
    LOG_INFO = 1 << 1,
    LOG_WARNING = 1 << 2,
    LOG_ERROR = 1 << 3
}LogLevel;
    
void setLogLevel(LogLevel level);
void setLogFilePath(NSString* filePath);
    
#else
    #define logMass(...) {}
    #define logInfo(...) {}
    #define logWarning(...) {}
    #define logError(...) {}
#endif
    
#ifdef __cplusplus
}
#endif


