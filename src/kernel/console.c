#include "type.h"
#include "defs.h"
#include "file.h"

#define C(x)  ((x)-'@')  // Control-x
#define INPUT_MAX 128
struct {
    struct spinlock slock;
    char buf[INPUT_MAX];
    uint r;
    uint w;
} cons;

int consolewrite(uint user_dst,uint64 src,int n){
    int i;
    for(i = 0; i< n;i++){
        char c;
        if(either_copy(&c,0,src,1) == -1){
            break;
        }
        uart_putc(c);
    }
    return i;
}

int consoleread(uint user_dst,uint64 dst,int n){
    lock(&cons.slock);

    int target = n;
    while (n > 0) {
        while (cons.r  == cons.w) {
            if(myproc()->killed){
                unlock(&cons.slock);
                return -1;
            }
            // sleep(&cons.r, &cons.slock);
        }
        
        char c = cons.buf[cons.r % INPUT_MAX];
        if(c == C('D')){
            if(n < target){
                cons.r --;
            }
            break;
        }

        char cbuf = c;
        if(either_copyout(user_dst, dst, &cbuf, 1) == -1){
            break;
        }

        dst++;
        --n;
        if(c == '\n'){
            break;
        }
    }
    unlock(&cons.slock);
    return target - n;
}

void consoleinit(){
    initlock(&cons.slock,"console");

    devsw[CONSOLE].read = consoleread;
    devsw[CONSOLE].write = consolewrite;
}