#include "type.h"
#include "defs.h"
#include "riscv.h"
#include "spinlock.h"
#include "memlayout.h"


extern void kernelvec();

struct spinlock slock;

void usertrap(){
            
}

static volatile int timer_processed_count = 0;

void kerneltrap(){
    printf("-------trap-------\n");
    // 判断是否是软件中断
    uint64 sstatus = r_sstatus();
    uint64 scause = r_scause();
    uint64 sepc = r_sepc();
    if((sstatus & SSTATUS_SPP) == 0){
        println("kerneltrap: interrupt from U Model");
        return;
    }
    if((r_sstatus() & SSTATUS_SIE) != 0){
        println("kerneltrap: Handle kernel interrupts SIE cannot be set");
        return;
    }
    if((scause & 0x8000000000000000) && (scause & 0xff) == 9){
        int irq = plic_claim();
        if(irq == UART0_IRQ){
            uartinterrupt();
        }else if(irq == VIRTIO0_IRQ){
            // VIRTIO interrupter code
            virtio_disk_isr();
        }else{
            printf("unknow irq processed:%d\n",irq);
        }
        if(irq){
            complate_irq(irq);
        }
    }else if(scause == 0x8000000000000001){
        w_sip(r_sip() & ~2);
        printf("ttt\n");
        // timer_processed_count++;
        // int current_tasks = get_tasks();
        // if(0 == current_tasks){
        //     return;
        // }
        // int task_num = timer_processed_count % current_tasks;
        // printf("timer switch num:%d\n",task_num);
        // run_target_task_num(task_num);
    }else{
        printf("sepc=%p stval=%p\n scause=%d\n", r_sepc(), r_stval(),r_scause());
        panic("kernel trap\n");
    }
    
    w_sepc(sepc);
    w_sstatus(sstatus);
}

void trapinit(){
    w_stvec((uint64)kernelvec);
    initlock(&slock,"trap");
}