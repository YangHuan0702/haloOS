#include "kernel/defs.h"
#include "kernel/proc.h"

int os_main(){
    println("Halo OS\n");
    printf("OS start\n");
    struct context ctx_task;
    struct context ctx_os;
	ctx_task.ra = (uint64) user_task0;
	ctx_task.sp = (uint64) &task0_stack[STACK_SIZE-1];
	swtch(&ctx_os, &ctx_task);
    return 0;
}