#include "type.h"
#include "memlayout.h"
#include "defs.h"
#include <stdarg.h>


static char nums[] = "0123456789abcdef";



void printinit(){
    uartinit();
}

static void printInt(int val,int u){
    char buf[16];
    int i = 0;
    do
    {
        buf[i++] = nums[val % 10];        
    } while ((val /= 10) > 0);
    for(i-=1;i >= 0; i--){
        uart_putc(buf[i]);
    }
}


static void printPtr(uint64 ptr){
    if(!ptr)
        return;
    uart_putc('0');
    uart_putc('x');
    
    for(int i = 0; i < (sizeof(uint64) * 2); i++,ptr <<= 4){
        uart_putc(nums[ptr >> sizeof(uint64) * 8 - 4]);
    }
}


void printP(uint64 ptr){
    uart_putc('0');
    uart_putc('x');
    char buff[32];    
    
    int a,i;
    do {
        a = ptr % 16;
        buff[i++] = nums[a];
    } while ((ptr /= 16) > 0);
    for(i-=1;i >= 0; i--){
         uart_putc(buff[i]);
    }
}



void printf(char *s, ...){
    if(s == 0){
        return;
    }
    va_list ap;
    va_start(ap,s);
    char *str;
    for(int i = 0; s[i] != 0; i++){
        char c = s[i];
        if(c != '%'){
            uart_putc(c);
            continue;
        }
        char next = s[++i];
        if(next == 0){
            uart_putc(c);
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
            uart_putc(next);
            break;
        }
    }    
}


void print(char *s){
    uart_putstr(s);
}

void println(char *s){
    char *nextLine = "\n";
    uart_putstr(s);
    uart_putstr(nextLine);
}
