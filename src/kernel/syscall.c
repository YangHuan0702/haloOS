#include "type.h"
#include "defs.h"
#include "syscall.h"
#include "proc.h"

extern uint64 sys_write(void);
extern uint64 sys_exec(void);
extern uint64 sys_dup(void);
extern uint64 sys_open(void);
extern uint64 sys_wait(void);

static uint64 (*syscall[])(void) = {
    [SYS_WRITE]     sys_write,
    [SYS_EXEC]      sys_exec,
    [SYS_DUP]       sys_dup,
    [SYS_OPEN]      sys_open,
    [SYS_WAIT]      sys_wait,
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
