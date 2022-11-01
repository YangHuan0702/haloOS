#include "type.h"
#include "vm.h"
#include "defs.h"
#include "spinlock.h"
#include "riscv.h"
#include "memlayout.h"

struct run{
    struct run *next;
};
extern char end[];
extern char etext[];
extern char trampoline[]; 
pagetable_t kernel_pagetable;

struct {
    struct spinlock lk;
    struct run *freelist;
} kmem;

void kfree(void *pa){
    struct run *r;
    if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP){
        panic("kfree");
    }
    memset(pa,1,PGSIZE);

    r = (struct run*)pa;
    acquire(&kmem.lk);
    r->next = kmem.freelist;
    kmem.freelist = r;
    release(&kmem.lk);
}


void freerange(void *pa_start,void *pa_end){
    char *p;
    p = (char*)PGROUNDUP((uint64)pa_start);
    for(;p + PGSIZE <= (char*)pa_end; p+=PGSIZE){
        kfree(p);  
    }

}


void* kalloc(){
    struct run *r;
    acquire(&kmem.lk);
    r = kmem.freelist;
    if(r){
        kmem.freelist = r->next;
    }
    release(&kmem.lk);
    if(r){
        memset((char*)r,5,PGSIZE);
    }
    return (void*)r;
}

pte_t* walk(pagetable_t pagetable,uint64 va,int alloc){
    if(va > MAXVA){
        panic("walk va overflow...\n");
    }
    for(int level = 2; level > 0;level--){
        pte_t *pte = &pagetable[PX(level,va)];
        if(*pte & PTE_V){
            pagetable = (pagetable_t)PTE2PA(*pte);
        }else{
            if(!alloc || (pagetable = (pte_t*)kalloc()) == 0){
                return 0;
            }
            memset(pagetable, 0, PGSIZE);
            *pte = PA2PTE(pagetable) | PTE_V;
        }                                                                                                                                                                                     
    }
    return &pagetable[PX(0, va)];
}


int mappages(pagetable_t pagetable,uint64 va,uint64 sz,uint64 pa,int perm){
    uint64 a,last;
    pte_t *pte;

    if(sz == 0){
        panic("mappages: sz");
    }
    a = PGROUNDDOWN(va);
    last = PGROUNDDOWN(va + sz -1);
    for(;;){
        if((pte = walk(pagetable,a,1)) == 0){
            return -1;
        }
        if(*pte & PTE_V){
            panic("mappages: no validator");
        }
        *pte = PA2PTE(pa) | perm | PTE_V;
        if(a == last){
            break;
        }
        a += PGSIZE;
        pa += PGSIZE;
    }
    return 0;
}


void kvmmap(pagetable_t kpg,uint64 va,uint64 pa,uint64 sz,int perm){
    if(mappages(kpg,va,sz,pa,perm) != 0){
        panic("kvmmap");
    }
}

pagetable_t kvmmake(){
    pagetable_t kpg;
    kpg = (pagetable_t) kalloc();
    
    memset(kpg,0,PGSIZE);

    kvmmap(kpg, UART, UART, PGSIZE, PTE_R | PTE_W);

    kvmmap(kpg, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);

    kvmmap(kpg, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    
    kvmmap(kpg, KERNELBASE, KERNELBASE, (uint64)etext-KERNELBASE, PTE_R | PTE_X);

    kvmmap(kpg, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);

    kvmmap(kpg, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    
    proc_mapstacks(kpg);

    return kpg;
}


void kinit(){
    initlock(&kmem.lk,"kmem");
    freerange(end,(void*)PHYSTOP);

    kernel_pagetable = kvmmake();

    w_satp(MAKE_SATP(kernel_pagetable));
    sfence_vma();
}