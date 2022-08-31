#include "memlayout.h"

void uart_putstr(char* s){
    while (*s)
    {
          uart_putc(*s++); 
    }
}

void uart_putc(char c){
    while ((ReadReg(LSR) & LM5) == 0){}
    WriteReg(THR,c);
}