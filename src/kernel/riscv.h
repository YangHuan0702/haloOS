#include "type.h"

#define SSTATUS_SPP (1L << 8)  // Previous mode, 1=Supervisor, 0=User
#define SSTATUS_SPIE (1L << 5) // Supervisor Previous Interrupt Enable
#define SSTATUS_UPIE (1L << 4) // User Previous Interrupt Enable
#define SSTATUS_SIE (1L << 1)  // Supervisor Interrupt Enable
#define SSTATUS_UIE (1L << 0)  // User Interrupt Enable

static inline uint64
read_sstatus()
{
  uint64 x;
  asm volatile("csrr %0, sstatus" : "=r" (x) );
  return x;
}

static inline void 
write_sstatus(uint64 x)
{
  asm volatile("csrw sstatus, %0" : : "r" (x));
}


static inline void
intr_on()
{
  write_sstatus(read_sstatus() | SSTATUS_SIE);
}

static inline void
intr_off()
{
  write_sstatus(read_sstatus() & ~SSTATUS_SIE);
}


// MSTATUS
#define MSTATUS_MIE (1 << 3)
#define MSTATUS_MPP_MASK (3 << 11) //之前的模式
#define MSTATUS_MPP_M (3L << 11)
#define MSTATUS_MPP_S (1L << 11)
#define MSTATUS_MPP_U (0L << 11)


#define MIE_MTIE (1 << 7)

#define SIE_SEIE (1L << 9) // 外部中断
#define SIE_STIE (1L << 5) // 时间中断
#define SIE_SSIE (1L << 1) // 软件中断




static inline uint64 read_sie(){
    uint64 x;
    asm volatile("csrr %0,sie":"=r"(x));
    return x;
}

static inline void write_sie(uint64 x){
    asm volatile("csrw sie,%0"::"r"(x));
}

static inline uint64 read_sip(){
    uint64 x;
    asm volatile("csrr %0,sip" : "=r"(x));
    return x;
}


static inline uint64 read_stvec(){
    uint64 x;
    asm volatile("csrr %0,stvec":"=r"(x));
    return x;
}

static inline void write_stvec(uint64 x){
    asm volatile("csrw stvec, %0" : : "r" (x));
}

static inline void write_mscratch(uint64 x){
    asm volatile("csrw mscratch, %0" : : "r" (x));
}

static inline void write_medeleg(uint64 x){
    asm volatile("csrw medeleg,%0"::"r"(x));
}

static inline void write_mideleg(uint64 x){
    asm volatile("csrw mideleg,%0"::"r"(x));
}

static inline void write_satp(uint64 x){
    asm volatile("csrw satp,%0" :: "r"(x));
}

static inline void
write_pmpaddr0(uint64 x)
{
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
}

static inline void
write_pmpcfg0(uint64 x)
{
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
}

static inline void write_tp(uint64 x){
    asm volatile("mv tp,%0"::"r"(x));
}

static inline uint64 read_mepc(){
    uint64 x;
    asm volatile("csrr %0,mepc":"=r"(x));
    return x;
}

static inline void write_mepc(uint64 x){
    asm volatile("csrw mepc,%0" : : "r"(x));
}

static inline uint64 read_mtvec(){
    uint64 x;
    asm volatile("csrr %0,mtvec":"=r"(x));
    return x;
}

static inline void write_mtvec(uint64 x){
    asm volatile("csrw mtvec, %0" : : "r"(x));
}

static inline void write_mstatus(uint64 x){
    asm volatile("csrw mstatus, %0" : : "r" (x));
}

static inline uint64 read_mhartid(){
    uint64 x;
    asm volatile("csrr %0,mhartid": "=r"(x));
    return x;
}

static inline uint64 read_mstatus(){
    uint64 x;
    asm volatile("csrr %0,mstatus" : "=r"(x));
    return x;    
}

static inline uint64 write_mie(uint64 x){
    asm volatile("csrw mie,%0" :: "r"(x));
}
static inline uint64 read_mie(){
    uint64 x;
    asm volatile("csrr %0,mie" : "=r"(x));
    return x;
}

static inline uint64 read_mip(){
    uint64 x;
    asm volatile("csrr %0,mip" : "=r"(x));
    return x;
}