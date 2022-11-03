#include "type.h"
#include "defs.h"
#include "file.h"
#include "fs.h"
#include "proc.h"
#include "elf.h"
#include "riscv.h"

static int loadseg(pagetable_t pagetable,uint64 va,struct inode *ip,struct proghdr ph,uint64 off,uint64 sz){
    int n = 0;
    for(int i = 0; i < sz;i += PGSIZE){
        uint64 pa = walkaddr(pagetable,va + i);
        if(pa == 0){
            panic("loadseg: address should exist");
        }
        if(sz - i  < PGSIZE){
            n = sz - i;
        }else{
            n = PGSIZE;
        }
        if(readi(ip,0,(uint64)pa,off+i,n) != n){
            return -1;
        }
    }
    return 0;
}

int exec(char *path,char** argv){
    path+=1;
    struct inode *app = rootsub(path);
    ilock(app);
    struct proc *p = myproc();

    pagetable_t pagetable = proc_pagetable(p);
    if(pagetable == 0){
        panic("exec proc_pagetable panic\n");
    }
    uint64 sz = 0;

    struct elfhdr elf;
    struct proghdr ph;
    if(readi(app,0,(uint64)&elf,0,sizeof(elf)) != sizeof(elf)){
        panic("readi panic");
    }
    if(elf.magic != ELF_MAGIC){
        panic("ELF MAGIC Panic");
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
        uint64 sz1;
        if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0){
            panic("loadseg uvmalloc panic");
        }
        sz = sz1;
        if(loadseg(pagetable,ph.vaddr,app,ph,ph.off,ph.filesz) < 0){
            panic("loadseg panic");
        }
    }
    iunlockput(app);
    uint64 oldsz = p->sz;

    sz = PGROUNDUP(sz);
    uint64 sz1;
    if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0){
        panic("----");
    }
    sz = sz1;
    uvmclear(pagetable, sz-2*PGSIZE);
    uint64 sp = sz;

    p->trapframe->a1 = sp;

    char *s,*last;
    for(last=s=path; *s; s++){
        if(*s == '/'){
            last = s+1;
        }
    }

    pagetable_t oldpagetable = p->pagetable;
    safestrcpy(p->name, last, sizeof(p->name));
    p->pagetable = pagetable;
    p->sz = sz;
    p->trapframe->epc = elf.entry;
    p->trapframe->sp = sp;
    proc_freepagetable(oldpagetable, oldsz);
    return 0;

}