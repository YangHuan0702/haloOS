#include "proc.h"
#include "defs.h"


char task0_stack[STACK_SIZE];
int os_main(){
    print("Halo OS\n");
    print("OS start\n");
    int a = 1;
    printf("a:%p\n",&a);
    printP((uint64)&a);
     print("\n");
    struct context ctx_task;
    struct context ctx_os;
	ctx_task.ra = (uint64) user_task0;
	ctx_task.sp = (uint64) &task0_stack[STACK_SIZE-1];
	swtch(&ctx_os, &ctx_task);
    return 0;
}