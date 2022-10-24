#include "type.h"
#include "defs.h"
#include "fs.h"
#include "file.h"

#define NBUF 16
#define INODES 32

#define min(a,b) ((a) > (b) ? (b) : (a))

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

void initfs(){
    readsb();
    if(sb.magic != FSMAGIC){
        panic("invalid file system");
    }
    
}

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

static struct buf* bget(uint dev,uint blockno){
    struct buf* r
    lock(&bcache.slock);
    for(r = bcache.head.next; r != &bcache.head; r = r->next){
        if(r.dev == dev && r.blockno = blockno){
            r.refcnt++;
            unlock(&bcache.slock);
            return r;
        }
    }
    for(r = bcache.head.prev; r != &bcache.head; r = r->prev){
        if(r->refcnt == 0){
            r->refcnt = 1;
            r->vaild = 0;
            r->dev =dev;
            r->blockno = blockno;
            unlock(&bcache.slock);
            return r;
        }
    }
    unlock(&bcache.slock);
    panic("bget panic..\n");
}


struct buf* bread(uint dev,uint blockno){
    struct buf *r;
    r = bget(dev,blockno);
    if(!r->vaild){
        virt_disk_rw(r, 0);
        r->vaild = 1;
    }
    return r; 
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


int readi(struct inode* ip,int user_dst,uint64 dst,uint off,uint n){
    if(off > ip->size || off + n < off) {
        return 0;
    }
    if(off + n > ip->size) {
        n = ip->size - off;
    }
    struct buf *b;
    uint tot,m;
    for(tot = 0; tot < n; tot+=m,dst+=m){
        b = bread(ip->dev,bmap(ip,off/BSIZE));
        m = min(n - tot,BSIZE - off % BSIZE);
        if(copyout(user_dst,dst,b->data + (off % BSIZE),m) == -1){
            tot = -1;
            break;
        }
    }
    return tot;
}


struct inode* iget(uint dev,uint inum){
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


struct inode* inodeByName(struct inode* ip,char* name){
    int off;
    struct dirent de;
    for(off = 0; off < ip->size; off += sizeof(de)){
        if(readi(ip,0,(uint64)&de,off,sizeof(de)) != sizeof(de)){
            panic("inodeByName panic...\n");
        }
        if(strncmp(name,de.name,DIRSIZ) == 0){
            return iget(ip->dev,de.inum);
        }
    }
    return 0;    
}


struct inode* ialloc(uint dev,short type) {
    int inum;
    struct buf *bp;
    struct dinode *d;
    for(inum = 0;inum < sb.ninodes; inum++){
        bp = bread(dev,IBLOCK(inum,sb));
        d = (struct dinode*)bp->data + inum % IPB;
        if(d->type == 0){
            memset(d,0,sizeof(*d));
            d->type = type;
            return iget(dev,inum);
        }
    }
    return 0;
}

void iupdate(struct inode *ip){
    struct buf *b = bread(ip->dev,IBLOCK(ip->inum,sb));
    struct dinode *dip = (struct dinode*)b->data + ip->inum%IPB;
    dip->type = ip->type;
    dip->major = ip->major;
    dip->minor = ip->minor;
    dip->nlink = ip->nlink;
    dip->size = ip->size;
    memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    // TODO : already write to cache buf , now should write to log 
}

int writei(struct inode *ip,int user_src,uint64 src,uint off, uint n){

    return -1;
}

int dirlink(struct inode *dp,char *path,short inum){
    struct dirent dir;
    
    int off;
    for(off = 0; off < dp->size; off += sizeof(dir)){
        if(readi(dp,0,(uint64)&dir,off,sizeof(dir)) != sizeof(dir)){
            panic("dirlink panic...\n");
        }
        if(dir.inum == 0){
            break;
        }
    }

    strncmp(dir.name,path,DIRSIZ);
    dir.inum = inum;

    writei(dp,0,(uint64)&dir,off,sizeof(dir));
    return 0;
}