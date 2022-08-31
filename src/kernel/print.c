#include "memlayout.h"
#include "defs.h"

void printf(char *s, ...){
    if(s == 0){
        return;
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
