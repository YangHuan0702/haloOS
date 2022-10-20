#include "type.h"
#include "defs.h"


static uint64 argptr(int num){
    struct proc *proc = mycpu();
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
    }
    panic("argptr panic");
    return -1;
}

void argaddr(int n,uint64 *addr){
    *addr = argptr(n);
}

// TODO before need finish to Virtual Memory
int getstr(uint64 addr,char *buf,int size){
    return -1;
}

int argstr(int num,char *buf,int size){
    uint64 addr;
    argaddr(num,&addr);
    return getstr(addr,buf,size);
}