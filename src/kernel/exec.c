#include "type.h"
#include "defs.h"
#include "file.h"
#include "spinlock.h"
#include "proc.h"
#include "elf.h"

int exec(char *path,char** argv){
    struct inode *node = rooti();
    path+=1;
    ilock(node);
    struct inode *app = inodeByName(node,path);
    struct proc *p = myproc();

    struct elfhdr elf;
    struct proghdr ph;
    printf("----------");
    if(readi(app,0,(uint64)&elf,0,sizeof(elf)) != sizeof(elf)){
        return -1;
    }
    printf("------");
    if(elf.magic != ELF_MAGIC){
        return -1;
    }
    int i,off;
    for(i=0,off=elf.phoff; i< elf.phnum;i++,off+=sizeof(ph)){
        if(readi(app,0,(uint64)&ph,off,sizeof(ph)) != sizeof(ph)){
            panic("readi from proghdr panic...\n");
        }
        if(ph.type!= ELF_PROG_LOAD){
            continue;
        }
        if(ph.memsz < ph.filesz){
            panic("exec() ph.memsz < ph.filesz...\n");
        }
        if(ph.vaddr + ph.memsz < ph.vaddr){
            panic("exec() ph.vaddr + ph.memsz < ph.vaddr...\n");
        }
    }
    p->trapframe->epc = elf.entry;
    printf("exec success");
    return 0;

}