#include "type.h"
#include "defs.h"
#include "riscv.h"


void usertrap(){
}

static int timer_processed_count = 0;

void kerneltrap(){
    println("kernel trap...");
    timer_processed_count++;
    int current_tasks = get_tasks();
    if(0 == current_tasks){
        return;
    }
    int task_num = timer_processed_count % current_tasks;
    printf("timer switch num:%d\n",task_num);
    run_target_task_num(task_num);
    // 进入中断后，SIE会被设置为0 屏蔽中断。且SIE之前的值保存在SPIE中
    intr_on();
}

void trapinit(){
    write_stvec((uint64)kerneltrap);
}