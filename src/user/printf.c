#include "src/kernel/type.h"
#include "src/kernel/stat.h"
#include "users.h"

#include <stdarg.h>

static char nums[] = "0123456789abcdef";

void putc(int fd, char c)
{
  write(fd, &c, 1);
}

static void printInt(int val,int u){
    char buf[16];
    int i = 0;
    do
    {
        buf[i++] = nums[val % 10];
    } while ((val /= 10) > 0);
    for(i-=1;i >= 0; i--){
        putc(1,buf[i]);
    }
}

void print(char *s){
    while (*s) {
        putc(1,*(s++));
    }
}

static void printPtr(uint64 ptr){
    if(!ptr)
        return;
    putc(1,'0');
    putc(1,'x');
    
    for(int i = 0; i < (sizeof(uint64) * 2); i++,ptr <<= 4){
        putc(1,nums[ptr >> (sizeof(uint64) * 8 - 4)]);
    }
}

void printf(char *s,...){
     if(s == 0){
        return;
    }
    va_list ap;
    va_start(ap,s);
    char *str;
    for(int i = 0; s[i] != 0; i++){
        char c = s[i];
        if(c != '%'){
            putc(1,c);
            continue;
        }
        char next = s[++i];
        if(next == 0){
            putc(1,c);
            continue;
        }
        switch (next) {
        case 'd':
            printInt(va_arg(ap,int),1);
            break;
        case 's':
            str = va_arg(ap,char*);
            if(str){
                print(str);
            }
        break;
        case 'p':
            printPtr(va_arg(ap,uint64));
        break;
        default:
            putc(1,next);
            break;
        }
    }
}

