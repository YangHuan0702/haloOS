#include "proc.h"
#include "defs.h"
#include "riscv.h"

int main(){
    intr_on();
    print("OS: Start\n");
    trapinit();
    user_init();
    while(1){
    }    
    return 0;
}