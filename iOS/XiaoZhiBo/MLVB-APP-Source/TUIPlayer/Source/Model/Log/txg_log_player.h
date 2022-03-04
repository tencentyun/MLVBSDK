//
//  txg_log_player.h
//  Pods
//
//  Created by 林智 on 2020/11/13.
//

#ifndef txg_log_player_h
#define txg_log_player_h

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#endif

typedef enum {
	TXE_LOG_VERBOSE = 0,
	TXE_LOG_DEBUG,
	TXE_LOG_INFO,
	TXE_LOG_WARNING,
	TXE_LOG_ERROR,
	TXE_LOG_FATAL,
	TXE_LOG_NONE,
} TXELogLevel;

void txf_log(TXELogLevel level, const char *file, int line, const char *func, const char *format, ...);

void txf_log_swift(TXELogLevel level, const char *file, int line, const char *func, const char *content);

#ifdef __cplusplus
}
#endif

#define LOGE(fmt, ...) \
    txf_log(TXE_LOG_ERROR, __FILE__, __LINE__, __FUNCTION__, fmt, ##__VA_ARGS__)
#define LOGW(fmt, ...) \
    txf_log(TXE_LOG_WARNING, __FILE__, __LINE__, __FUNCTION__, fmt, ##__VA_ARGS__)
#define LOGI(fmt, ...) \
    txf_log(TXE_LOG_INFO, __FILE__, __LINE__, __FUNCTION__, fmt, ##__VA_ARGS__)
#define LOGD(fmt, ...) \
    txf_log(TXE_LOG_DEBUG, __FILE__, __LINE__, __FUNCTION__, fmt, ##__VA_ARGS__)
#define LOGV(fmt, ...) \
    txf_log(TXE_LOG_VERBOSE, __FILE__, __LINE__, __FUNCTION__, fmt, ##__VA_ARGS__)

#endif /* txg_log_player_h */
