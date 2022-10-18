#include "src/kernel/syscall.h"

.global write
write:
    li a7,SYS_WRITE
    ecall
    ret
