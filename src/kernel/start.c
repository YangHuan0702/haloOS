#include "type.h"
#include "defs.h"
#include "riscv.h"
#include "memlayout.h"

int main();

void timer_init();

static int timer_processed_count = 0;
void timer_handler(){
    printf("Time Processed Count : %d\n",timer_processed_count++);
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

    // 开启中断
    write_mie(read_mie() | SIE_SEIE | SIE_STIE | SIE_SSIE);

    timer_init();
   
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