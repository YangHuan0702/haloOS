#include "type.h"
#include "defs.h"
#include "file.h"
#include "fcntl.h"
#include "fs.h"

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

static struct inode* create(char *path,short type,short major,short minor){
    struct inode *ip,*dp;
    dp = iget(ROOTDEV,ROOTINO);

    if(path == '/'){
        path++;
    }
    if((ip = inodeByName(dp,path)) != 0){
        if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE)){
            return ip;
        }
    }
    if((ip = ialloc(dp->dev,type)) == 0){
        panic("fs.c create >> ialloc panic..\n");
    }
    ip->major = major;
    ip->minor = minor;
    ip->nlink = 1;
    iupdate(ip);

    dp->nlink ++;
    iupdate(dp);
    
    if(dirlink(dp,path,ip->inum) < 0){
        panic("create >> dirline panic...\n");
    }
    return ip;
}

uint64 sys_open(){
    char path[MAXPATH];
    int fd,model;
    int n;
    if((n = argstr(0,path,MAXPATH)) < 0 || argint(1,&model) < 0){
        return -1;
    }
    
    struct inode *ip;

    if(model & O_CREATE){
        // create file
        ip = create(path,T_FILE,0,0);
        if(ip == 0){
            return -1;
        }
    }else{
        ip = inodeByName(path);
        if(ip == 0){
            return -1;
        }
    }

    if(ip->type = T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
        return -1;
    }

    struct file *f;
    if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
        // TODO fs close
        return -1;
    }

    if(ip->type == T_DEVICE){
        f->type = FD_DEVICE;
        f->major = ip->major;
    }else{
       f->type = FD_INODE;
       f->off = 0;
    }
    f->ip = ip;
    f->readable = !(model & O_WRONLY);
    f->writable = (model & O_WRONLY) | (model & O_RDWR);
    return fd;
}