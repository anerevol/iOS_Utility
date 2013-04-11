

@class NSString;


#ifdef __cplusplus
extern "C" {
#endif
    
#define ENABLE_LOG 1
#ifdef ENABLE_LOG
// 普通描述信息
     void _LogInfo(NSString*, ...);

// 警告信息
     void _LogWarning(NSString*, ...);

// 错误信息
     void _LogError(NSString*, ...);
    
#define LogInfo(format, arg...) {NSString* newFormat = [NSString stringWithFormat:@"%s:%@", __func__, format]; _LogInfo(newFormat, ##arg);}
    
#define LogWarning(format, arg...) {NSString* newFormat = [NSString stringWithFormat:@"%s:%@", __func__, format]; _LogWarning(newFormat, ##arg);}
    
#define LogError(format, arg...) {NSString* newFormat = [NSString stringWithFormat:@"%s:%@", __func__, format]; _LogError(newFormat, ##arg);}

// 设置日志配置文件路径    
    extern void LogReadConfig(NSString* logConfigFilePath);
    
#else
    #define LogInfo(...) {}
    #define LogWarning(...) {}
    #define LogError(...) {}
#endif
    
#ifdef __cplusplus
}
#endif


