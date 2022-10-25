#include "src/kernel/syscall.h"

.global write
write:
    li a7,SYS_WRITE
    ecall
    ret

.global open
open:
    li a7,SYS_OPEN
    ecall
    ret

.global dup
dup:
    li a7,SYS_DUP
    ecall
    ret
