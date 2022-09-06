#include "proc.h"
#include "defs.h"
#include "riscv.h"

int main(){
    print("OS: Start\n");
    trapinit();
    user_init();
    asm volatile("csrw sip,2");
    while(1){
    }    
    return 0;
}