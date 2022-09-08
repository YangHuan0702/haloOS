#include "proc.h"
#include "defs.h"
#include "riscv.h"
#include "spinlock.h"

int main(){
    // intr_on();
    print("OS: Start\n");
    trapinit();
    user_init();
    struct spinlock s;
    lock(&s);
    lock(&s);
    while(1){
    }    
    return 0;
}