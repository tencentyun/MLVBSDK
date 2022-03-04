//
//  txg_log_player.c
//  trtc_cloud_plugin
//
//  Created by 林智 on 2020/11/13.
//

#include "txg_log_player.h"

void txf_log_swift(TXELogLevel level, const char *file, int line, const char *func, const char *content) {
	txf_log(level, file, line, func, content);
}
