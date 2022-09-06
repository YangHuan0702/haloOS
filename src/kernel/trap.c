#include "type.h"
#include "defs.h"
#include "riscv.h"


void usertrap(){
    println("...\n");
}


void kerneltrap(){
    println("kernel trap...");
}

void trapinit(){
    write_stvec((uint64)kerneltrap);
}