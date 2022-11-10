#include "type.h"
#include "defs.h"
#include "riscv.h"
#include "spinlock.h"
#include "file.h"
#include "proc.h"

int copyoutpg(pagetable_t pagetable, uint64 dstva, char *src, uint64 len) {
  uint64 n, va0, pa0;

  while(len > 0){
    va0 = PGROUNDDOWN(dstva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);

    len -= n;
    src += n;
    dstva = va0 + PGSIZE;
  }
  return 0;
}

int either_copyout(int user_dst,uint64 dst,void *src,uint64 len){
    struct proc *p = myproc();
    if(user_dst){
        // kernel -> user
        return copyoutpg(p->pagetable, dst, src, len);
    }else{
        memmove((char*)dst,src,len);
        return 0;
    }
    return -1;
}

int either_copyin(void *dst,int user_src,uint64 src,uint64 len) {
    struct proc *p  = myproc();
    if(user_src){
        // user -> kernel
        return copyin(p->pagetable, dst, src, len);
    }else{
        memmove(dst,(char*)src,len);
        return 0;
    }
    return -1;
}

char* safestrcpy(char *s, const char *t, int n) {
  char *os;

  os = s;
  if(n <= 0)
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    ;
  *s = 0;
  return os;
}