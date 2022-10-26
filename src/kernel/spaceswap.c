#include "type.h"
#include "defs.h"

uint copyout(int user_dst,uint64 dst,void *src,int n){
    if(user_dst){
        // copyout to user space
        return 0;
    }else{
        memmove((char*) dst,src,n);
        return 0;
    }
}

int either_copyout(int user_dst,uint64 dst,void *src,uint64 len){
    struct proc *p = myproc();
    if(user_dst){
        // kernel -> user
    }else{
        memmove((char*)dst,src,len);
        return 0;
    }
    return -1;
}

int either_copy(void *dst,int user_src,uint64 src,uint64 len) {
    struct proc *proc  = myproc();
    if(user_src){
        // user -> kernel
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