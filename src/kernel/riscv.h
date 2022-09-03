#include "type.h"

// MSTATUS
#define MSTATUS_MIE (1 << 3)

static inline uint64 read_mstatus(){
    int x;
    asm volatile("csrr %0,mstatus" : "=r"(x));
    return x;    
}

static inline uint64 read_mie(){
    int x;
    asm volatile("csrr %0,mie" : "=r"(x));
    return x;
}

static inline uint64 read_mip(){
    int x;
    asm volatile("csrr %0,mip" : "=r"(x))
    return x;
}