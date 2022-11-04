#include "type.h"
#include "defs.h"
#include "file.h"
#include "fs.h"
#include "proc.h"
#include "elf.h"
#include "riscv.h"
#include "param.h"

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
        if((ph.vaddr % PGSIZE) != 0){
            panic("exec:(ph.vaddr %% PGSIZE) != 0");
        }
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
    uint64 stackbase = sp - PGSIZE;

    uint64 argc = 0;
    uint64 ustack[MAXARG];
    if(argv){
        for(argc = 0; argv[argc]; argc++) {
            if(argc >= MAXARG){
                panic("argc >= MAXARG");
            }
            sp -= strlen(argv[argc]) + 1;
            sp -= sp % 16; // riscv sp must be 16-byte aligned
            if(sp < stackbase){
                panic("exec:sp < stackbase");
            }
            if(copyoutpg(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0){
                panic("exec:copyout");
            }
            ustack[argc] = sp;
        }
    }
    ustack[argc] = 0;
    sp -= (argc+1) * sizeof(uint64);
    sp -= sp % 16;
    if(sp < stackbase){
        panic("if(sp < stackbase)");
    }
    if(copyoutpg(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0){
        panic("exec:copyout");     
    }
    p->trapframe->a1 = sp;

    char *s,*last;
    for(last=s=path; *s; s++){
        if(*s == '/'){
            last = s+1;
        }
    }
    safestrcpy(p->name, last, sizeof(p->name));

    pagetable_t oldpagetable = p->pagetable;
    p->pagetable = pagetable;
    p->sz = sz;
    p->trapframe->epc = elf.entry;
    p->trapframe->sp = sp;
    proc_freepagetable(oldpagetable, oldsz);
    return 0;
}