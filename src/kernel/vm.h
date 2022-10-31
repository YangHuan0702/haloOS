#define MAXVA (1L << (9 + 9 + 9 + 12 - 1))
#define PGSIZE 4096
#define PGSHIFT 12  // bits of offset within a page

#define KERNELBASE 0x80000000L
#define PHYSTOP (KERNELBASE + 128*1024*1024)

#define PXMASK      0x1FF // 9 bits
#define PXSHIFT(level)  (PGSHIFT+(9*(level)))
#define PX(level,va)    ((((uint64) (va)) >> PXSHIFT(level)) & PXMASK)


#define TRAMPOLINE (MAXVA - PGSIZE)
#define KSTACK(p) (TRAMPOLINE - ((p)+1)* 2*PGSIZE)

typedef uint64 pte_t;
typedef uint64 *pagetable_t;