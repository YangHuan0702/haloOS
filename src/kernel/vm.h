#define MAXVA (1L << (9 + 9 + 9 + 12 - 1))
#define PGSIZE 4096

#define TRAMPOLINE (MAXVA - PGSIZE)
#define KSTACK(p) (TRAMPOLINE - ((p)+1)* 2*PGSIZE)