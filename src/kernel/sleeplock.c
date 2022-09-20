#include "type.h"
#include "defs.h"
#include "sleeplock.h"

void sleep_initlock(struct sleeplock* sl,char* name){
    initlock(sl->locked,name);
    sl->name = name;
    sl->locked = 0;
    // sl->pid = getpid();
}

void sleep_lock(struct sleeplock *sl){
    lock(sl->locked);
    while (sl->locked) {
        // sleep();
    }
    sl->locked = 1;
    unlock(sl->locked);
}

void sleep_unlock(struct sleeplock *sl){
    sl->locked = 0;
}