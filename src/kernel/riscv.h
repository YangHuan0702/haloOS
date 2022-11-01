#include "type.h"
#include "memlayout.h"



#define PGROUNDUP(sz)  (((sz)+PGSIZE-1) & ~(PGSIZE-1))
#define PGROUNDDOWN(a) (((a)) & ~(PGSIZE-1))

#define PA2PTE(pa) ((((uint64)pa) >> 12) << 10)
#define PTE2PA(pte) (((pte) >> 10) << 12)

#define SATP_SV39 (8L << 60)
#define MAKE_SATP(pagetable) (SATP_SV39 | (((uint64)pagetable) >> 12))

#define PTE_V (1L << 0) // valid
#define PTE_R (1L << 1)
#define PTE_W (1L << 2)
#define PTE_X (1L << 3)
#define PTE_U (1L << 4) // 1 -> user can access


static inline void sfence_vma(){
    asm volatile("sfence.vma zero, zero");
}

static inline uint64 r_stval(){
    uint64 x;
    asm volatile("csrr %0,stval":"=r"(x));
    return x;
}

static inline uint64 r_sstatus() {
  uint64 x;
  asm volatile("csrr %0, sstatus" : "=r" (x) );
  return x;
}

static inline void w_sstatus(uint64 x) {
  asm volatile("csrw sstatus, %0" : : "r" (x));
}

static inline int intr_get(){
    return (r_sstatus() & SSTATUS_SIE) != 0;
}

static inline void intr_on() {
  w_sstatus(r_sstatus() | SSTATUS_SIE);
}

static inline void intr_off() {
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
}

static inline uint64 r_spie(){
    uint64 x;
    asm volatile("csrr %0,spie":"=r"(x));
    return x;
}

static inline void w_sepc(uint64 x){
    asm volatile("csrw sepc,%0"::"r"(x));
}

static inline uint64 r_sepc(){
    uint64 x;
    asm volatile("csrr %0,sepc":"=r"(x));
    return x;
}

static inline uint64 r_scause(){
    uint64 x;
    asm volatile("csrr %0,scause":"=r"(x));
    return x;
}

static inline uint64 r_sie(){
    uint64 x;
    asm volatile("csrr %0,sie":"=r"(x));
    return x;
}

static inline void w_sie(uint64 x){
    asm volatile("csrw sie,%0"::"r"(x));
}

static inline uint64 r_sip() {
    uint64 x;
    asm volatile("csrr %0,sip" : "=r"(x));
    return x;
}

static inline void w_sip(uint64 x) {
    asm volatile("csrw sip,%0"::"r"(x));
}

static inline uint64 r_stvec() {
    uint64 x;
    asm volatile("csrr %0,stvec":"=r"(x));
    return x;
}

static inline void w_stvec(uint64 x) {
    asm volatile("csrw stvec, %0" : : "r" (x));
}

static inline void w_mscratch(uint64 x){
    asm volatile("csrw mscratch, %0" : : "r" (x));
}

static inline void w_medeleg(uint64 x){
    asm volatile("csrw medeleg,%0"::"r"(x));
}

static inline void w_mideleg(uint64 x){
    asm volatile("csrw mideleg,%0"::"r"(x));
}

static inline void w_satp(uint64 x){
    asm volatile("csrw satp,%0" :: "r"(x));
}

static inline void w_pmpaddr0(uint64 x) {
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
}

static inline void w_pmpcfg0(uint64 x) {
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
}

static inline uint64 r_tp(){
    uint64 x;
    asm volatile("mv %0,tp":"=r"(x));
    return x;
}

static inline void w_tp(uint64 x){
    asm volatile("mv tp,%0"::"r"(x));
}

static inline uint64 r_mepc(){
    uint64 x;
    asm volatile("csrr %0,mepc":"=r"(x));
    return x;
}

static inline void w_mepc(uint64 x){
    asm volatile("csrw mepc,%0" : : "r"(x));
}

static inline uint64 r_mtvec(){
    uint64 x;
    asm volatile("csrr %0,mtvec":"=r"(x));
    return x;
}

static inline void w_mtvec(uint64 x){
    asm volatile("csrw mtvec, %0" : : "r"(x));
}

static inline void w_mstatus(uint64 x){
    asm volatile("csrw mstatus, %0" : : "r" (x));
}

static inline uint64 r_mhartid(){
    uint64 x;
    asm volatile("csrr %0,mhartid": "=r"(x));
    return x;
}

static inline uint64 r_mstatus(){
    uint64 x;
    asm volatile("csrr %0,mstatus" : "=r"(x));
    return x;    
}

static inline void w_mie(uint64 x){
    asm volatile("csrw mie,%0" :: "r"(x));
}

static inline uint64 r_mie(){
    uint64 x;
    asm volatile("csrr %0,mie" : "=r"(x));
    return x;
}

static inline uint64 r_mip(){
    uint64 x;
    asm volatile("csrr %0,mip" : "=r"(x));
    return x;
}