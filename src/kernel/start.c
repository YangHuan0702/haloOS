#include "type.h"
#include "defs.h"
#include "riscv.h"
#include "memlayout.h"

int main();

void timer_init();

static int timer_processed_count = 0;
void timer_handler(){
    // timer_processed_count++;
    // int current_tasks = get_tasks();
    // if(0 == current_tasks){
    //     return;
    // }
    // int task_num = timer_processed_count % current_tasks;
    // run_target_task_num(task_num);
}

void start(){
    // 将先前的M模式设置为S，用于mret
    unsigned long x = read_mstatus(); 
    x &= ~MSTATUS_MPP_MASK; // M
    x |= MSTATUS_MPP_S;
    write_mstatus(x);

    write_mepc((uint64)main);

    // 禁用分页，在初始化阶段的时候再开启
    write_satp(0);

    write_medeleg(0xffff);  // 异常委派处理
    write_mideleg(0xffff);  // 中断委派处理

    write_pmpaddr0(0x3fffffffffffffull);
    write_pmpcfg0(0xf); // 读，写，执行，启用此PMP

    // 开启中断
    write_mie(read_mie() | SIE_SEIE | SIE_STIE | SIE_SSIE);

    timer_init();

    write_tp(read_mhartid());

    asm volatile("mret");
}

void timer_init(){
    uint64 hartid = read_mhartid();
    // 设置下一个时钟周期
    *(uint64*)CLINT_MTIMECMP(hartid) = *(uint64*)CLINT_MTIME + INTERVAL;

    write_mtvec((uint64)timer_handler);

    write_mstatus(read_mstatus() | MSTATUS_MIE);

    write_mie(read_mie() | MIE_MTIE);
}