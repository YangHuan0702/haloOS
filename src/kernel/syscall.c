#include "type.h"
#include "defs.h"
#include "syscall.h"

extern uint64 sys_write(void);

static uint64 (*syscall[])(void) = {
    [SYS_WRITE] sys_write,
}

void syscall(){
    
}