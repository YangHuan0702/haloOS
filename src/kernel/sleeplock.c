#include "type.h"
#include "defs.h"
#include "spinlock.h"
#include "sleeplock.h"

void sleep_initlock(struct sleeplock* sl,char* name){
    initlock(&sl->splock,name);
    sl->name = name;
    sl->locked = 0;
    // sl->pid = getpid();
}

void sleep_lock(struct sleeplock *sl){
    acquire(&sl->splock);
    while (sl->locked) {
        // sleep();
    }
    sl->locked = 1;
    release(&sl->splock);
}

void sleep_unlock(struct sleeplock *sl){
    sl->locked = 0;
}