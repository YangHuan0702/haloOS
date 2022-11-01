#include "type.h"
#include "defs.h"
#include "riscv.h"

volatile static int started = 0;

int main(){
    if(cpuid() == 0){
        consoleinit();
        printinit();
        trapinit();
        plicinit();
        plicinithart();
        kinit();
        initproc();
        init_bcache();
        init_inodecache();
        init_filecache();
        virtio_disk_init();
        userinit();
        __sync_synchronize();
        print("OS: Start\n");
        started = 1;
    }else{
        while (started == 0) {
        }
        __sync_synchronize();
        trapinit();   
        plicinithart();
    }
    scheduler();

    return 0;
}