#include "type.h"
#include "defs.h"
#include "file.h"

static int argfd(int n,int *pfd,struct file **fe){
    int fd;
    struct file *f;
    if(argint(n,&fd) != 0){
        return -1;
    }
    if(fd < 0 || fd >= OPENFILE || (f = myproc()->openfs[fd]) == 0){
        return -1;
    }
    if(pfd){
        *pfd = fd;
    }
    if(fe){
        *fe = f;
    }
    return 0;
}


static int fdalloc(struct file *f){
    int fd;
    struct proc *p = myproc();

    for(fd = 0; fd < OPENFILE;fd++){
        if(p->openfs[fd] == 0){
            p->openfs[fd] = f;
            return fd;
        }
    }
    return -1;
}


uint64 sys_exec(){
    char *path = "/init";
    int ret = exec(path,0);
    return ret;
}

uint64 sys_dup(){
    struct file *f;
    int fd;

    if(argfd(0,0,f) < 0){
        return -1;
    }
    if((fd = fdalloc(f)) < 0){
        return -1;
    }
    filedup(f);
    return fd;
}


