#include "../kernel/syscall.h"

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
.global exec
exec:
    li a7,SYS_EXEC
    ecall
    ret
.global wait
wait:
    li a7,SYS_WAIT
    ecall
    ret
.global mknod
mknod:
    li a7,SYS_MKNOD
    ecall
    ret
