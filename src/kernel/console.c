#include "type.h"
#include "defs.h"
#include "file.h"

#define INPUT_MAX 128
struct {
    struct spinlock slock;
    char buf[INPUT_MAX];
    uint r;
    uint w;
} cons;

int consolewrite(uint user_dst,uint64 src,int n){
    return -1;
}

int consoleread(uint user_dst,uint64 dst,int n){
    return -1;
}

void consoleinit(){
    initlock(&cons.slock,"console");

    devsw[CONSOLE].read = consoleread;
    devsw[CONSOLE].write = consolewrite;
}