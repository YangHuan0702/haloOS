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

void uvmclear(pagetable_t pagetable,uint64 va){
    pte_t *pte;
    pte = walk(pagetable,va,0);
    if(pte == 0){
        panic("uvmclear");
    }
    *pte &= ~PTE_U;
}

void
uvmfree(pagetable_t pagetable, uint64 sz) {
  if(sz > 0){

    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  }
  freewalk(pagetable);
}

void
freewalk(pagetable_t pagetable)
{
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
}

void proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

uint64 walkaddr(pagetable_t pagetable,uint64 va){
    if(va >= MAXVA){
        return 0;
    }
    pte_t *pte = walk(pagetable,va,0); 
    if(pte == 0){
        return 0;
    }
    if((*pte & PTE_V) == 0){
        return 0;
    }
    if((*pte & PTE_U) == 0){
        return 0;
    }
    uint64 pa = PTE2PA(*pte);
    return pa;
}

void kinit(){
    initlock(&kmem.lk,"kmem");
    freerange(end,(void*)PHYSTOP);

    kernel_pagetable = kvmmake();

    w_satp(MAKE_SATP(kernel_pagetable));
    sfence_vma();
}


uint64 uvmalloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz){
    if(newsz < oldsz){
        return oldsz;
    }
    oldsz = PGROUNDUP(oldsz);
    for(uint64 a = oldsz; a < newsz; a += PGSIZE){
        char *mem = kalloc();
        if(mem == 0){
            uvmdealloc(pagetable, a, oldsz);
            return 0;
        }
        memset(mem, 0, PGSIZE);
        if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
            kfree(mem);
            uvmdealloc(pagetable, a, oldsz);
            return 0;
        }
    }
    return newsz;
}

void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free) {
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0){
    panic("uvmunmap: not aligned");
  }

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    if((pte = walk(pagetable, a, 0)) == 0){
      panic("uvmunmap: walk");
    }
    if((*pte & PTE_V) == 0){
      panic("uvmunmap: not mapped");
    }
    if(PTE_FLAGS(*pte) == PTE_V){
      panic("uvmunmap: not a leaf");
    }
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}


uint64 uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz){
    if(newsz >= oldsz){
        return oldsz;
    }

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }
  return newsz;
}

void uvminit(pagetable_t pagetable,uchar* src,uint sz){
    char *mem;
    if(sz > PGSIZE){
        panic("inituvm: more than a page");
    }    
    mem = kalloc();
    memset(mem,0,PGSIZE);
    mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    memmove(mem, src, sz);
}

pagetable_t uvmcreate(){
    pagetable_t pagetable;
    pagetable = (pagetable_t) kalloc();

    if(pagetable == 0){ 
        panic("uvmcreate kalloc panic..\n");
    }    
    memset(pagetable,0,PGSIZE);
    return pagetable;
}

int copyin(pagetable_t pagetable,void *dest,uint64 src,uint64 len){
    uint64 n,va0,pa0;
    while (len > 0) {
        va0 = PGROUNDDOWN(src);
        pa0 = walkaddr(pagetable,va0);
        if(pa0 == 0){
            return -1;
        }
        n = PGSIZE - (src + va0);
        if(n > len){
            n = len;
        }
        memmove(dest,(void*)(pa0 + (src - va0)),n);

        len -= n;
        dest += n;
        src = va0 + PGSIZE;
    }
    return 0;
}

int copyinstr(pagetable_t pagetable,char *dst,uint64 va,uint64 max){
    int got_null = 0;
    while (got_null == 0 && max > 0) {
        uint64 va0 = PGROUNDDOWN(va);
        uint64 pa0 = walkaddr(pagetable,va0);
        if(pa0 == 0){
            return -1;
        }
        uint64 n = PGSIZE - (va - va0);
        if(n > max){
            n = max;
        }
        char *p = (char*)(pa0 + (va - va0));
        while(n > 0){
            if(*p == '\0'){
                *dst = '\0';
                got_null = 1;
                break;
            } else {
                *dst = *p;
            }
            --n;
            --max;
            p++;
            dst++;
        }
        va = va0 + PGSIZE;
    }
    if(got_null){
        return 0;
    } else {
        return -1;
    }
}