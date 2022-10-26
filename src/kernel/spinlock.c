#include "type.h"
#include "defs.h"
#include "memlayout.h"
#include "spinlock.h"
#include "file.h"
#include "proc.h"
#include "riscv.h"

extern int atmswap(int *lock);


void initlock(struct spinlock *lock,char *name){
    lock->name = name;
    lock->locked = 0;
}

void acquire(struct spinlock *lock){
    while (atmswap(&lock->locked) != 0){}
}

void release(struct spinlock *lock){
    lock->locked = 0;
}


int holdinglock(struct spinlock *lk){
    int r = (lk->locked && lk->cpu == mycpu());
    return r;
}

void push_off(){
    int intr = intr_get();
    intr_off();
    struct cpu *c = mycpu();
    if(c->noff == 0){
        c->intena = intr;
    }
    c->noff += 1;
}


void pop_off(){
    struct cpu *c = mycpu();
    int intr = intr_get();
    if(intr){
        panic("pop off - interruptible");   
    }
    if(c->noff < 1){
        panic("pop_off() c->noff");
    }
    c->noff -= 1;
    if(c->noff == 0 && c->intena){
        intr_on();
    }
}
