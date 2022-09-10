#include "proc.h"
#include "defs.h"
#include "riscv.h"
#include "spinlock.h"

int main(){
    intr_on(); //方便测试，关闭中断
    print("OS: Start\n");
    printinit();
    trapinit();
    user_init();
    while(1){
    }    
    return 0;
}