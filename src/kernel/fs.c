#include "type.h"
#include "defs.h"
#include "fs.h"
#include "file.h"

#define NBUF 16
#define INODES 32

struct superblock sb;

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
    return 0;
}


struct buf* bread(uint dev,uint blockno){
    struct buf *r;
    bget();

    return 0; 
}


static uint balloc(uint dev){
    for(int b = 0; b < sb.size; b += BPB){
        struct buf *bp = bread(dev,BMAPBLOCK(b,sb));
        for(int bi = 0; bi < BPB && b + bi < sb.size;bi++){
            int m = 1 << (bi % 8);
            if((bp->data[bi/8] & m) == 0){
                bp->data[bi/8] |= m;
                return b+bi;
            }
        }
    }
    panic("balloc panic...\n");
    return -1;
}

static uint bmap(struct inode* ip,uint n){
    uint addr;
    if(n < NDIRECT){
        if((addr = ip->addrs[n]) == 0){
            addr = ip->addrs[n] = balloc(ip->dev);
        }
        return addr;
    }
    n -= NDIRECT;
    if(n < NINDIRECT){
        if((addr = ip->addrs[NDIRECT]) == 0){
            ip->addrs[NDIRECT] = addr = balloc(ip->dev);
        }
        struct buf *bp = bread(ip->dev, addr);
        uint *a = (uint*)bp->data;
        if((addr = a[n]) == 0){
            a[n] = addr = balloc(ip->dev);
        }
        return addr;
    }
    panic("bmap panic...\n");
}


struct inode* readi(struct inode* ip,int user_dst,uint64 dst,uint off,uint n){
    if(off > ip->size || off + n < off) {
        return 0;
    }
    if(off + n > ip->size) {
        n = ip->size - off;
    }
    struct buf *b;
    uint tot,m;
    for(tot = 0; tot < n; tot+=m,dst+=m){
        bread(ip->dev,bmap(ip,off/BSIZE));
    }
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
        panic("getInodeByDevAndINum panic");
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

