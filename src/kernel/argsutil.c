#include "type.h"
#include "defs.h"
#include "file.h"
#include "fs.h"
#include "proc.h"

static uint64 argptr(int num){
    struct proc *proc = myproc();
    switch (num) {
    case 0:
        return proc->trapframe->a0;
    case 1:
        return proc->trapframe->a1;
    case 2:
        return proc->trapframe->a2;
    case 3:
        return proc->trapframe->a3;
    case 4:
        return proc->trapframe->a4;
    case 5:
        return proc->trapframe->a5;  
    }
    return -1;
}

int argaddr(int n,uint64 *addr){
    *addr = argptr(n);
    return 0;
}

int fetchstr(uint64 addr, char *buf, int max) {
  struct proc *p = myproc();
  int err = copyinstr(p->pagetable, buf, addr, max);
  if(err < 0){
    panic("fetchstr err < 0");
    return err;
  }
  return strlen(buf);
}

int argstr(int num,char *buf,int size){
    uint64 addr;
    if(argaddr(num,&addr) < 0){
        return -1;
    }
    return fetchstr(addr,buf,size);
}

int argint(int n,int *ip){
    *ip = argptr(n);
    return 0;
}