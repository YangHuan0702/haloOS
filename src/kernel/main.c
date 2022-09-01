#include "defs.h"
#include "proc.h"

char task0_stack[STACK_SIZE];
int os_main(){
    print("Halo OS\n");
    print("OS start\n");
    printf("a:%d\n",153);
    struct context ctx_task;
    struct context ctx_os;
	ctx_task.ra = (uint64) user_task0;
	ctx_task.sp = (uint64) &task0_stack[STACK_SIZE-1];
	swtch(&ctx_os, &ctx_task);
    return 0;
}