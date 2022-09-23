#include "type.h"
#include "defs.h"
#include "fs.h"
#include "file.h"

#define NBUF 16
#define INODES 32

struct {
    struct spinlock slock;
    struct buf bufs[NBUF];
    struct buf head;
} bcache;

struct {
    struct spinlock slock;
    struct inode inodes[INODES];
} inodecache;


void init_bcache() {
    bcache.slock.locked = 0;
    bcache.slock.name = "bcache";

    for(int i = 0; i < NBUF; i++){
        bcache.bufs[i].refcnt = 0;
        sleep_initlock(&bcache.bufs[i].sk,"buf");
        bcache.bufs[i].vaild = 0;
        bcache.bufs[i].disk = 0;
    }
}

void init_inodecache() {
    initlock(&inodecache.slock,"inodecache");
    for(int i = 0; i < INODES; i++){
        inodecache.inodes[i].ref = 0;
        inodecache.inodes[i].vaild = 0;
        sleep_initlock(&inodecache.inodes[i].splock,"inode");        
    }
}


int open(char *path, int model){

    int fd;

    // 创建
    if(model & O_CREATE){
        
    } 


    return 0;
}


void bread(){
    
}
