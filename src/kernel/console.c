#include "type.h"
#include "defs.h"
#include "file.h"
#include "spinlock.h"
#include "proc.h"
#include "memlayout.h"

#define C(x)  ((x)-'@')  // Control-x
#define INPUT_MAX 128
struct {
    struct spinlock slock;
    char buf[INPUT_MAX];
    uint r;
    uint w;
    uint e;
} cons;

int consolewrite(int user_src,uint64 src,int n){
    int i;
    for(i = 0; i< n;i++){
        char c;
        if(either_copyin(&c,user_src,src+i,1) == -1){
            break;
        }
        uartputc(c);
    }
    return i;
}

int consoleread(int user_dst,uint64 dst,int n){
    acquire(&cons.slock);

    int target = n;
    while (n > 0) {
        while (cons.r == cons.w) {
            if(myproc()->killed) {
                release(&cons.slock);
                return -1;
            }
            sleep(&cons.r, &cons.slock);
        }
        char c = cons.buf[cons.r++ % INPUT_MAX];
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
    release(&cons.slock);
    return target - n;
}

void consoleinit(){
    initlock(&cons.slock,"console");

    devsw[CONSOLE].read = consoleread;
    devsw[CONSOLE].write = consolewrite;
}



void consoleintr(int c){
    acquire(&cons.slock);
    switch (c) {
    case C('U'):
        while(cons.e != cons.w &&
          cons.buf[(cons.e-1) % INPUT_MAX] != '\n'){
            cons.e--;
            consputc(BACKSPACE);
        }
        break;
    case C('H'):
    case '\x7f':
        if(cons.e != cons.w){
            cons.e--;
            consputc(BACKSPACE);
        }
        break;
    default:
        if(c != 0 && cons.e - cons.r < INPUT_MAX){
            c = (c == '\r') ? '\n' : c;
            consputc(c);
            cons.buf[cons.e++ % INPUT_MAX] = c;
            if((c == '\n' || c == C('D')) || cons.e == cons.r + INPUT_MAX){
                cons.w = cons.e;
                wakeup(&cons.r);
            }
        }
        break;
    }
    release(&cons.slock);
}
