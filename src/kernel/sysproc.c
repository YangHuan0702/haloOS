#include "type.h"
#include "fs.h"
#include "defs.h"

uint64 sys_wait(){
    uint64 p;
    if(argaddr(0,&p) < 0){
        return -1;
    }
    return wait(p);
}