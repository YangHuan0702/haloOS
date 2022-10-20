#include "type.h"
#include "defs.h"
#include "syscall.h"
#include "proc.h"

extern uint64 sys_write(void);
extern uint64 sys_exec(void);

static uint64 (*syscall[])(void) = {
    [SYS_WRITE] sys_write,
    [SYS_EXEC]  sys_exec,
}

void syscall(){
    int num;
    struct proc *proc = myproc();
    num = proc->trapframe->a7;
    if(syscall[num]){
        proc->trapframe->a0 = syscall[num]();
    }else{
        printf("syscall %d not exist \n",num);
        proc->trapframe->a0 = -1;
    }
}
