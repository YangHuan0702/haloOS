#include "type.h"
#include "defs.h"
#include "riscv.h"
#include "memlayout.h"

void usertrap(){
}

static int timer_processed_count = 0;

void kerneltrap(){
    // 判断是否是软件中断
    uint64 sstatus = r_sstatus();
    uint64 scause = r_scause();
    if((sstatus & SSTATUS_SPP) == 0){
        println("kerneltrap: interrupt from U Model");
        return;
    }
    if((r_sstatus() & SSTATUS_SIE) != 0){
        println("kerneltrap: Handle kernel interrupts SIE cannot be set");
        return;
    }
    printf("scause : %p----%d\n",scause,scause);
    if((scause & 0x8000000000000000) && (scause & 0xff) == 9){
        // S Model External interrupt
        int irq = plic_claim();
        if(irq == UART0_IRQ){
            println("UART0_IRQ JOIN");
            uartinterrupt();
        }else{
            printf("unknow irq processed:%d\n",irq);
        }

    }else if(scause == 0x8000000000000001){
        // 时间中断
        // timer_processed_count++;
        // int current_tasks = get_tasks();
        // if(0 == current_tasks){
        //     return;
        // }
        // int task_num = timer_processed_count % current_tasks;
        // printf("timer switch num:%d\n",task_num);
        // run_target_task_num(task_num);
    }else{
        printf("unknow trap processor,scause:%p\n",scause);
    }
    
    // 进入中断后，SIE会被设置为0 屏蔽中断。且SIE之前的值保存在SPIE中
    intr_on();
}

void trapinit(){
    w_stvec((uint64)kerneltrap);
}