#include "type.h"
#include "defs.h"
#include "file.h"
#include "fs.h"
#include "fcntl.h"
#include "proc.h"
#include "stat.h"
#include "param.h"


int fetchaddr(uint64 addr,uint64 *ip){
    struct proc *p = myproc();
    if(addr >= p->sz || addr+sizeof(uint64) > p->sz){
        panic("fetchaddr:addr >= p->sz || addr+sizeof(uint64) > p->sz");
        return -1;
    }
    if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0){
        panic("fetchaddr:copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0");
        return -1;
    }
    return 0;
}

static int argfd(int n,int *pfd,struct file **fe){
    int fd;
    struct file *f;
    if(argint(n,&fd) != 0){
        return -1;
    }
    if(fd < 0 || fd >= OPENFILE || (f = myproc()->openfs[fd]) == 0){
        printf("n:%d,fd:%d,proc:%s\n",n,fd,myproc()->name);
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

uint64 sys_read(){
    int sz;
    uint64 p;
    struct file *f;
    if(argfd(0,0,&f) < 0 || argint(2,&sz) < 0 || argaddr(1,&p) < 0){
        panic("sys_read param failure\n");
    }
    return fileread(f,p,sz);
}

// uint64 sys_exec(){
//     char name[MAXPATH];
//     if(argstr(0,name,MAXPATH) < 0) {
//         return -1;
//     };
//     printf("exec: %s,p.name:%s,p.id:%d\n",name,myproc()->name,myproc()->pid);
//     int ret = exec(name,0);
//     return ret;
// }

uint64
sys_exec() {
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
    if(i >= NELEM(argv)){
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
        printf("fetchaddr r < 0");
        goto bad;
    }
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0){
      goto bad;
    }
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
        panic("exec:fetchstr");
        goto bad;
    }
  }
  printf("exec: %s,p.name:%s,p.id:%d\n",path,myproc()->name,myproc()->pid);
  int ret = exec(path, argv);

  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    kfree(argv[i]);
  return -1;
}



uint64 sys_dup(){
    struct file *f;
    int fd;

    if(argfd(0,0,&f) < 0){
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
    dp = rooti();
    ilock(dp);
    if(*path == '/'){
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
    ilock(ip);
    ip->major = major;
    ip->minor = minor;
    ip->nlink = 1;
    iupdate(ip);

    if(type == T_DIR){
        iupdate(dp);
        if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0){
            panic("create dots");
        }
    }

    if(dirlink(dp,path,ip->inum) < 0){
        panic("create >> dirline panic...\n");
    }
    iunlockput(dp);
    return ip;
}

uint64 sys_mknod(){
    struct inode *ip;
    char path[MAXPATH];
    int major, minor;
    if(argstr(0, path, MAXPATH) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
        (ip = create(path, T_DEVICE, major, minor)) == 0){
        panic("sys_mknod");
        return -1;
    }
    iunlockput(ip);
    return 0;
}

uint64 sys_write() {
    struct file *f;
    int n;
    uint64 p;
    if(argfd(0,0,&f) < 0 || argint(2,&n) < 0 || argaddr(1,&p) < 0){
        return -1;
    }
    return filewrite(f,p,n);
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
        ip = iname(path);
        if(ip == 0){
            printf("ip == 0 \n");
            return -1;
        }
    }
    ilock(ip);

    if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
        return -1;
    }

    struct file *f;
    if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
        fileclose(f);
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
    iunlock(ip);
    return fd;
}