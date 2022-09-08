#include "type.h"
#include "defs.h"
#include "memlayout.h"
#include "spinlock.h"

extern int atmswap(struct spinlock *lock);


void lock(struct spinlock *lock){
    while (atmswap(lock) != 0){}
    printf("lock:%d\n",lock->locked);
}

void unlock(struct spinlock *lock){
    lock->locked = 0;
}