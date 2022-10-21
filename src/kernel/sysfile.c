#include "type.h"
#include "defs.h"


uint64 sys_exec(){
    char *path = "/init";
    int ret = exec(path,0);
    return ret;
}