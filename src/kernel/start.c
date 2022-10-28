#include "type.h"
#include "defs.h"
#include "riscv.h"
#include "memlayout.h"

int main();
void timer_init();

__attribute__ ((aligned (16))) char stack0[4096 * NCPU];

uint64 timer_scratch[NCPU][5];

extern void timervec();

void start(){
    // 将先前的M模式设置为S，用于mret
    unsigned long x = r_mstatus(); 
    x &= ~MSTATUS_MPP_MASK;
    x |= MSTATUS_MPP_S;
    w_mstatus(x);

    w_mepc((uint64)main);

    // 禁用分页，在初始化阶段的时候再开启
    w_satp(0);

    w_medeleg(0xffff);  // 异常委派处理
    w_mideleg(0xffff);  // 中断委派处理
    w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE); // 开启S Model下的中断处理
    
    // 硬件内存保护寄存器，在硬件层面开放内存地址的访问权限
    w_pmpaddr0(0x3fffffffffffffull);   // 2^38 - 1
    w_pmpcfg0(0xf); // 读，写，执行，启用此PMP

    timer_init();

    w_tp(r_mhartid());

    asm volatile("mret");
}

void timer_init(){
    uint64 hartid = r_mhartid();
    // 设置下一个时钟周期
    *(uint64*)CLINT_MTIMECMP(hartid) = *(uint64*)CLINT_MTIME + INTERVAL;

    uint64 *scratch = &timer_scratch[hartid][0];
    scratch[3] = CLINT_MTIMECMP(hartid);
    scratch[4] = INTERVAL;
    w_mscratch((uint64)scratch);

    w_mtvec((uint64)timervec);

    w_mstatus(r_mstatus() | MSTATUS_MIE);

    w_mie(r_mie() | MIE_MTIE);
}