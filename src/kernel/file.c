#include "type.h"
#include "defs.h"
#include "file.h"
#include "fs.h"

#define NFILE 100

struct devsw devsw[NDEV];

struct {
    struct spinlock slock;
    struct file files[NFILE];
} filecache;

void init_filecache(){
    initlock(&filecache.slock,"filecache");
    for(int i = 0;i < NFILE;i++){
        filecache.files[i].type = FD_NONE;
        filecache.files[i].ref = 0;
    }
}

struct file* filealloc(){
    struct file *f;
    acquire(&filecache.slock);
    for(f = filecache.files; f < filecache.files + NFILE; f++){
        if(f->ref == 0){
        f->ref = 1;
        release(&filecache.slock);
        return f;
        }
    }
    release(&filecache.slock);
    return 0;
}

void fileclose(struct file *f){
    acquire(&filecache.slock);
    if(f->ref < 1){
        panic("fileclose f ref < 1");
    }
    if(--f->ref > 0){
        release(&filecache.slock);
        return;
    }
    struct file ff = *f;
    f->ref = 0;
    f->type = FD_NONE;
    release(&filecache.slock);

    if(ff.type == FD_PIPE){

    }else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
        iput(ff.ip);
    }
}

int filewrite(struct file *f,uint64 p,int n){
    if(f->writable == 0){
        return -1;
    }
    int ret = 0;
    if(f->type == FD_PIPE){
        ret = 1;
    }else if(f->type == FD_DEVICE){
        if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write){
           return -1;
        }
        ret = devsw[f->major].write(1, p, n);
    }else if(f->type == FD_INODE){

    }else{
        panic("filewrite");
    }
    return ret;
}

int fileread(struct file *f,uint64 p,int n){
    if(f->readable == 0){
        return -1;
    }
    int ret = 0;
    if(f->type == T_DEVICE){
        if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read){
            return -1;
        }
        ret = devsw[f->major].read(1,p,n);
    }
    return ret;
}


struct  file* filedup(struct file* f){
    acquire(&filecache.slock);
    if(f->ref < 1){
        panic("filedup | target file ref < 1..");
    }
    f->ref++;
    release(&filecache.slock);
    return f;
} 

