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


uint64 sys_fork(){
    return fork();
}

uint64 sys_exit() {
  int n;
  if(argint(0, &n) < 0){
    return -1;
  }
  exit(n);
  return 0;
}