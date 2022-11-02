#include "type.h"
#include "defs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"
#include "proc.h"

void sleep_initlock(struct sleeplock* sl,char* name){
    initlock(&sl->splock,name);
    sl->name = name;
    sl->locked = 0;
    sl->pid = 0;
}

void sleep_lock(struct sleeplock *sl){
    acquire(&sl->splock);
    while (sl->locked) {
        sleep(sl,&sl->splock);
    }
    sl->locked = 1;
    sl->pid = myproc()->pid;
    release(&sl->splock);
}

void sleep_unlock(struct sleeplock *sl){
    acquire(&sl->splock);
    sl->locked = 0;
    sl->pid = 0;
    wakeup(sl);
    release(&sl->splock);
}

int holdingsleep(struct sleeplock *sl){
    int r;
    acquire(&sl->splock);
    r = sl->locked && (sl->pid == myproc()->pid);
    release(&sl->splock);
    return r;
}