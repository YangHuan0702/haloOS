#include "proc.h"
#include "defs.h"
#include "riscv.h"

int main(){
    intr_on();
    print("OS: Start\n");
    trapinit();
    user_init();
    while(1){
        if((read_sstatus() & SSTATUS_SIE) == 0){
            println("null");
        }else{
            println("true");
        }
    }    
    return 0;
}