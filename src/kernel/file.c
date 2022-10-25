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
    lock(&file.slock);
    for(int i = 0; i < NFILE;i++){
        struct file f = files[i];
        if(f.ref == 0){
            unlock(&file.slock);
            return &f;
        }
    }
    unlock(&file.slock);
    return 0;
}


struct  file* filedup(struct file* f){
    lock(&filecache.slock);
    if(f->ref < 1){
        panic("filedup | target file ref < 1..");
    }
    f->ref++;
    unlock(&filecache.slock);
    return f;
} 

