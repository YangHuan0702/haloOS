#include "type.h"
#include "defs.h"


uint64 sys_exec(){
    char *path = "init";
    exec(path,0);
}