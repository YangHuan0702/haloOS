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