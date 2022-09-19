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
    virtio_disk_init();
    intr_on();
    while(1){
        // printf("#: ");
        // while (getShellResult() == 0) {
        //     char *cmd = getCmd();
        //     if(cmd){
        //         printf("Handler: %s\n",cmd);
        //     }
        // }
        // intr_on();
    }    
    return 0;
}