#include "type.h"
#include "defs.h"
#include "riscv.h"
#include "spinlock.h"
#include "memlayout.h"
#include "file.h"
#include "proc.h"


extern void kernelvec();

struct spinlock slock;

extern char trampoline[], uservec[], userret[];

void usertrap();

void usertrapret(){
    struct proc *p = myproc();

    intr_off();

    w_stvec(TRAMPOLINE + (uservec - trampoline));

    p->trapframe->kernel_satp = r_satp();
    p->trapframe->kernel_sp = p->kstack + PGSIZE;
    p->trapframe->kernel_trap = (uint64)usertrap;
    p->trapframe->kernel_hartid = r_tp();

    unsigned long x = r_sstatus();
    x &= ~SSTATUS_SPP;
    x |= SSTATUS_SPIE;
    w_sstatus(x);

    w_sepc(p->trapframe->epc);
    uint64 satp = MAKE_SATP(p->pagetable);
    
    uint64 fn = TRAMPOLINE + (userret - trampoline);
    ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
}

static volatile int timer_processed_count = 0;

int devintr(){
     uint64 scause = r_scause();
     if((scause & 0x8000000000000000) && (scause & 0xff) == 9){
        int irq = plic_claim();
        if(irq == UART0_IRQ){
            uartinterrupt();
        }else if(irq == VIRTIO0_IRQ){
            virtio_disk_isr();
        }else{
            printf("unknow irq:%d\n",irq);
        }
        if(irq){
            complate_irq(irq);
        }
        return 1;
     }else if(scause == 0x8000000000000001L){
          w_sip(r_sip() & ~2);
          return 2;
     }else{
        return 0;
    }
}

void kerneltrap(){
    int which_dev;
    // 判断是否是软件中断
    uint64 sstatus = r_sstatus();
    uint64 sepc = r_sepc();
    if((sstatus & SSTATUS_SPP) == 0){
        println("kerneltrap: interrupt from U Model");
        return;
    }
    if((r_sstatus() & SSTATUS_SIE) != 0){
        println("kerneltrap: Handle kernel interrupts SIE cannot be set");
        return;
    }
    if((which_dev = devintr()) == 0){
        printf("sepc=%p stval=%p scause=%d\n", r_sepc(), r_stval(),r_scause());
        panic("kernel trap\n");
    }
    if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
        yield();
    }
    
    w_sepc(sepc);
    w_sstatus(sstatus);
}

void trapinit(){
    w_stvec((uint64)kernelvec);
    initlock(&slock,"trap");
}


void usertrap(){
    int which_dev = 0;
    if((r_sstatus() & SSTATUS_SPP) != 0){
        panic("usertrap: not from user mode");
    }
    w_stvec((uint64)kernelvec);
    struct proc *p = myproc();
    p->trapframe->epc = r_sepc();
    if(r_scause() == 8){
        p->trapframe->epc += 4;
        intr_on();
        syscall();
    }else if((which_dev = devintr()) != 0){
        // TODO
    } else {
        printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
        printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
        panic("user trap\n");
        // p->killed = 1;
    }
    if(which_dev == 2){
        yield();
    }
    usertrapret();
}