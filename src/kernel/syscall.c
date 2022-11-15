#include "type.h"
#include "defs.h"
#include "syscall.h"
#include "spinlock.h"
#include "file.h"
#include "proc.h"

extern uint64 sys_write(void);
extern uint64 sys_exec(void);
extern uint64 sys_dup(void);
extern uint64 sys_open(void);
extern uint64 sys_wait(void);
extern uint64 sys_mknod(void);
extern uint64 sys_fork(void);
extern uint64 sys_read(void);
extern uint64 sys_exit(void);
extern uint64 sys_sbrk(void);
extern uint64 sys_fstat(void);
extern uint64 sys_close(void);

static uint64 (*syscalls[])(void) = {
    [SYS_WRITE]     sys_write,
    [SYS_EXEC]      sys_exec,
    [SYS_EXEC2]     sys_exec,
    [SYS_DUP]       sys_dup,
    [SYS_OPEN]      sys_open,
    [SYS_WAIT]      sys_wait,
    [SYS_MKNOD]     sys_mknod,
    [SYS_FORK]      sys_fork,
    [SYS_READ]      sys_read,
    [SYS_EXIT]      sys_exit,
    [SYS_SBRK]      sys_sbrk,
    [SYS_FSTAT]     sys_fstat,
    [SYS_CLOSE]     sys_close,
};

void syscall(){
    int num;
    struct proc *proc = myproc();
    num = proc->trapframe->a7;
    if(num > 0 && num < NELEM(syscalls) && syscalls[num]){
        proc->trapframe->a0 = syscalls[num]();
    }else{
        printf("syscall %d not exist \n",num);
        proc->trapframe->a0 = -1;
    }
}
