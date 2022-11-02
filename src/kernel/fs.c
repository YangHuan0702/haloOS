#include "type.h"
#include "defs.h"
#include "fs.h"
#include "file.h"
#include "riscv.h"

#define NBUF 16
#define INODES 32

#define min(a,b) ((a) > (b) ? (b) : (a))

struct superblock sb;

struct buf* bread(uint,uint);

struct {
    struct spinlock slock;
    struct buf bufs[NBUF];
    struct buf head;
} bcache;

struct {
    struct spinlock slock;
    struct inode inodes[INODES];
} inodecache;

static void readsb(int dev,struct superblock *sb){
    struct buf *f = bread(dev,1);
    memmove(sb,f->data,sizeof(*sb));
}


void initfs(int dev){
    readsb(dev,&sb);
    if(sb.magic != FSMAGIC){
        panic("invalid file system");
    }
    // log init
}

void init_bcache() {
    initlock(&bcache.slock,"bcache");
    bcache.head.prev = &bcache.head;
    bcache.head.next = &bcache.head;

    struct buf *b;
    for(b = bcache.bufs; b < bcache.bufs+NBUF;b++){
        b->next = bcache.head.next;
        b->prev = &bcache.head;
        sleep_initlock(&b->sk, "buffer");
        bcache.head.next->prev = b;
        bcache.head.next = b;
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
    struct buf *r;
    acquire(&bcache.slock);
    for(r = bcache.head.next; r != &bcache.head; r = r->next){
        if(r->dev == dev && r->blockno == blockno){
            r->refcnt++;
            release(&bcache.slock);
            sleep_lock(&r->sk);
            return r;
        }
    }
    for(r = bcache.head.prev; r != &bcache.head; r = r->prev){
        if(r->refcnt == 0){
            r->refcnt = 1;
            r->vaild = 0;
            r->dev =dev;
            r->blockno = blockno;
            release(&bcache.slock);
            sleep_lock(&r->sk);
            return r;
        }
    }
    release(&bcache.slock);
    panic("bget panic..\n");
    return 0;
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
    return 0;
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
            brelease(b);
            break;
        }
        brelease(b);
    }
    return tot;
}


struct inode* iget(uint dev,uint inum){
    acquire(&inodecache.slock);
    struct inode* i;
    struct inode* r = 0;
    for(i = &inodecache.inodes[0]; i < &inodecache.inodes[INODES]; i++){
        if(i->ref > 0 && i->dev == dev && i->inum == inum){
            i->ref++;
            release(&inodecache.slock);
            return i;
        }
        if(i->ref == 0 && r == 0){
            r = i;
        }
    }
    if(r == 0){
        panic("getInodeByDevAndINum panic");
    }
    i = r;
    i->dev = dev;
    i->inum = inum;
    i->ref = 1;
    i->vaild = 0;
    release(&inodecache.slock);
    return i;
}

struct inode* rooti(){
    return iget(ROOTDEV,ROOTINO);
}


struct inode* iname(char *name){
    struct inode *i;
    struct inode *dp = iget(ROOTDEV,ROOTINO);
    ilock(dp);
    i = inodeByName(dp,name);
    return i;
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

void brelease(struct buf *b){
    if(!holdingsleep(&b->sk)){
        panic("brelease holdingsleep panic\n");
    }
    sleep_unlock(&b->sk);

    acquire(&bcache.slock);
    b->refcnt --;
    if(b->refcnt == 0){
        b->next->prev = b->prev;
        b->prev->next = b->next;
        b->next = bcache.head.next;
        b->prev = &bcache.head;
        bcache.head.next = b;
        bcache.head.next->prev = b;
    }
    release(&bcache.slock);
}

void ilock(struct inode* i){
    struct buf *b;
    struct dinode *dip;
    if(i == 0 || i->ref < 1){
        panic("ilock");
    }
    sleep_lock(&i->splock);

    if(i->vaild == 0){
        b = bread(i->dev,IBLOCK(i->inum,sb));

        dip = (struct dinode*) b->data + i->inum % IPB;
        i->type = dip->type;
        i->size = dip->size;
        i->major = dip->major;
        i->minor = dip->minor;
        i->nlink = dip->nlink;
        memmove(i->addrs,dip->addrs,sizeof(i->addrs));
        brelease(b);
        i->vaild = 0;
    }
}

void itrunc(struct inode *i){
    // TODO
}

void iunlock(struct inode *i){
    if( i == 0 || !holdingsleep(&i->splock) || i->ref < 1){
        panic("iunlock");
    }
    sleep_unlock(&i->splock);
}

void iput(struct inode *i){
    acquire(&inodecache.slock);
    if(i->ref == 1 && i->vaild && i->nlink == 0){
        sleep_lock(&i->splock);
    
        sleep_unlock(&i->splock);
    }
    i->ref --;
    release(&inodecache.slock);
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
    if(off > ip->size || off + n < off){
        return -1;
    }
    if(off + n > MAXFILE){
        return -1;
    }
    int tot,m;
    for(tot = 0; tot < n;tot += m,off += m,src += m){
        struct buf *bp = bread(ip->dev,bmap(ip,off%BSIZE));
        m = min(n-tot,BSIZE - off % BSIZE);
        if(either_copy(bp->data+(off%BSIZE),user_src,src,m) != m){
            break;
        }
        // log
    }
    if(off > ip->size){
        ip->size = off;
    }
    iupdate(ip);
    return tot;
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