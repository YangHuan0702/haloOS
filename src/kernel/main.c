#include "proc.h"
#include "defs.h"
#include "riscv.h"
#include "spinlock.h"

int main(){
   
    printinit();
    trapinit();
    plicinit();
    plicinithart();
    print("OS: Start\n");
    user_init();
    intr_on();
    while(1){
        // println("---main---");
        // intr_on();
    }    
    return 0;
}