#include "type.h"
#include "fs.h"
#include "defs.h"
#include "file.h"
#include "proc.h"

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


uint64 sys_sbrk(){
  int n;
  if(argint(0,&n) < 0){
    return -1;
  }
  int addr = myproc()->sz;
  if(growproc(n) < 0){
    return -1;
  }
  return addr;
}