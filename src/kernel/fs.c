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

static struct inode* create(char *path,short type,short major,short minor){
    
}



struct inode* getInodeByDevAndINum(uint dev,uint inum){
    lock(&inodecache.slock);
    struct inode* i;
    struct inode* r = 0;
    for(i = &inodecache.inodes[0]; i < &inodecache.inodes[INODES]; i++){
        if(i->ref > 0 && i->dev == dev && i->inum == inum){
            i->ref++;
            unlock(&inodecache.slock);
            return i;
        }
        if(i->ref == 0 && r == 0){
            r = i;
        }
    }
    if(r == 0){
        println("getInodeByDevAndINum panic");
        for(;;){
        }
    }

    r->dev = dev;
    r->inum = inum;
    r->ref = 1;
    r->vaild = 0;
    unlock(&inodecache.slock);
    return r;
}

int open(char *path, int model){

    int fd;

    struct inode *n;

    struct inode *parent = getInodeByDevAndINum(ROOTDEV,ROOTINO);

    // 创建
    if(model & H_CREATE){
        create();
    } 


    return 0;
}


void bread(){
    
}



