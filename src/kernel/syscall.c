#include "type.h"
#include "defs.h"
#include "syscall.h"
#include "spinlock.h"
#include "file.h"
#include "proc.h"

static uint64 argraw(int n) {
  struct proc *p = myproc();
  switch (n) {
  case 0:
    return p->trapframe->a0;
  case 1:
    return p->trapframe->a1;
  case 2:
    return p->trapframe->a2;
  case 3:
    return p->trapframe->a3;
  case 4:
    return p->trapframe->a4;
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
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
    *ip = argraw(n);
    return 0;
}

int
argaddr(int n, uint64 *ip)
{
  *ip = argraw(n);
  return 0;
}


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
