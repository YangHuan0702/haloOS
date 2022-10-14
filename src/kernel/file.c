#include "type.h"
#include "defs.h"
#include "file.h"
#include "fs.h"

#define NFILE 100

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
    println("filealloc error");
}