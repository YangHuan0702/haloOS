#include "type.h"

char* memset(void *target,int val,int end){
    char *upd = (char*) target;
    for(int i = 0;i < end; i++){
        upd[i] = val;
    }
    return upd;
}

void* memmove(void* dst,void* src,int n){
    if(n == 0){
        return dst;
    }
    const char *s = src;
    const char *d = dst;

    if(s < d && s + n > d ){
        s += n;
        d += n;
        while (n-- > 0) {
            *--d = *--s;
        }
    }else{
        while (n-- > 0) {
            *d++ = *s++;
        }
    }    
    return dst;
}

int strncmp(const char* a,const char* b,int n){
    while (n > 0 && *a == *b && *a) {
        n--;
        a++;
        b++;
    }
    if(n == 0){
        return 0;
    }
    return (uchar)*a - (uchar)*b;
}