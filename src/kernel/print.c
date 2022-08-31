#include "print.h"
#include "memlayout.h"

void printf(char *s, ...){

}

void println(char *s){
    char *nextLine = "\n";
    uart_putstr(s);
    uart_putstr(nextLine);
}
