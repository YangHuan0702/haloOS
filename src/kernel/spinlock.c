#include "type.h"
#include "defs.h"
#include "memlayout.h"
#include "spinlock.h"

extern int atmswap(int *lock);


void initlock(struct spinlock *lock,char *name){
    lock->name = name;
    lock->locked = 0;
}

void lock(struct spinlock *lock){
    while (atmswap(&lock->locked) != 0){}
}

void unlock(struct spinlock *lock){
    lock->locked = 0;
}