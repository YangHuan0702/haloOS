#include "memlayout.h"
#include "defs.h"
#include "type.h"

void printf(char *s, ...){
    if(s == 0){
        return;
    }
    va_list ap;
    va_start(s,ap);
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
            int d = va_arg(ap,int);

            break;
        case 's':
            char *str = va_arg(ap,char*);
            if(str){
                print(str);
            }
        break;
        case 'p'
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


static void printPtr(uint64 ptr){

}

