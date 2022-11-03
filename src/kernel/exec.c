#include "type.h"
#include "defs.h"
#include "file.h"
#include "fs.h"
#include "proc.h"
#include "elf.h"

int exec(char *path,char** argv){
    path+=1;
    struct inode *app = rootsub(path);
    ilock(app);
    struct proc *p = myproc();

    struct elfhdr elf;
    struct proghdr ph;
    if(readi(app,0,(uint64)&elf,0,sizeof(elf)) != sizeof(elf)){
        printf("readi panic");
        return -1;
    }
    if(elf.magic != ELF_MAGIC){
        printf("ELF MAGIC Panic");
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
    iunlockput(app);
    p->trapframe->epc = elf.entry;
    return 0;

}