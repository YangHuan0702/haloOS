#include "type.h"
#include "defs.h"
#include "riscv.h"
#include "memlayout.h"

int main();
void timer_init();


uint64 timer_scratch[NCPU][5];

extern void timervec();

// static int timer_processed_count = 0;
// void timer_handler(){
//     timer_processed_count++;
//     int current_tasks = get_tasks();
//     if(0 == current_tasks){
//         return;
//     }
//     int task_num = timer_processed_count % current_tasks;
//     printf("timer switch num:%d\n",task_num);
//     run_target_task_num(task_num);
// }

void start(){
    // 将先前的M模式设置为S，用于mret
    unsigned long x = read_mstatus(); 
    x &= ~MSTATUS_MPP_MASK;
    x |= MSTATUS_MPP_S;
    write_mstatus(x);

    write_mepc((uint64)main);

    // 禁用分页，在初始化阶段的时候再开启
    write_satp(0);

    write_medeleg(0xffff);  // 异常委派处理
    write_mideleg(0xffff);  // 中断委派处理
    write_sie(read_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE); // 开启S Model下的中断处理

    // 硬件内存保护寄存器，在硬件层面开放内存地址的访问权限
    write_pmpaddr0(0x3fffffffffffffull);   // 2^38 - 1
    write_pmpcfg0(0xf); // 读，写，执行，启用此PMP

    timer_init();

    write_tp(read_mhartid());

    asm volatile("mret");
}

void timer_init(){
    uint64 hartid = read_mhartid();
    // 设置下一个时钟周期
    *(uint64*)CLINT_MTIMECMP(hartid) = *(uint64*)CLINT_MTIME + INTERVAL;

    uint64 *scratch = &timer_scratch[hartid][0];
    scratch[3] = CLINT_MTIMECMP(hartid);
    scratch[4] = INTERVAL;
    write_mscratch((uint64)scratch);

    write_mtvec((uint64)timervec);

    write_mstatus(read_mstatus() | MSTATUS_MIE);

    write_mie(read_mie() | MIE_MTIE);
}