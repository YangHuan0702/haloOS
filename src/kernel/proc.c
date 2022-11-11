#include "type.h"
#include "defs.h"
#include "memlayout.h"
#include "file.h"
#include "spinlock.h"
#include "proc.h"
#include "riscv.h"
#include "vm.h"

struct cpu cpus[NCPU];

struct proc procs[NPROC];

struct proc *initp;

extern void forkret();

// a user program that calls exec("/init")
// od -t xC initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

extern char trampoline[];

struct spinlock pid_lock;
struct spinlock wait_lock;
volatile int nextPid = 1;


void forkret(){
	static int firstinit = 1;
	release(&myproc()->slock);

	if(firstinit){
		firstinit = 0;
		initfs(ROOTDEV);
	}
	usertrapret();
}

int cpuid(){
	int cpuid = r_tp();
	return cpuid;
}


void wakeup(void *chan){
	struct proc *p;
	for(p = procs;p < procs+NPROC; p++){
		if(p != myproc()){
			acquire(&p->slock);
			if(p->state == SLEEPING && p->chan == chan){
				p->state = RUNNABLE;
			}
			release(&p->slock);
		}
	}
}

struct cpu* mycpu(){
	int id = cpuid();
	return &cpus[id];
}

struct proc* myproc(){
	push_off();
	struct cpu *cpu = mycpu();
	struct proc *p = cpu->p;
	pop_off();
	return p;
}


void initproc(){
	struct proc *p;
	initlock(&pid_lock, "nextpid");
  	initlock(&wait_lock, "wait_lock");	
	
	for(p = procs; p < &procs[NPROC]; p++){
		initlock(&p->slock,"proc");
		p->kstack = KSTACK((int) (p - procs));
	}
}

int allocpid(){
	int pid;
	acquire(&pid_lock);
	pid = nextPid++;
	release(&pid_lock);
	return pid;
}


static void freeproc(struct proc *p){
	if(p->trapframe){
		// kfree
		kfree(p->trapframe);
	}
	p->trapframe = 0;
	p->pid = 0;
	p->chan = 0;
	p->parent = 0;
	p->name[0] = 0;
	p->killed = 0;
	p->state = UNUSED;
}


void proc_mapstacks(pagetable_t pg){
	struct proc *p;
	for(p = procs; p < &procs[NPROC]; p++){
		char *pa = kalloc();
		if(pa == 0){
			panic("proc_mapstacks kalloc...\n");
		}
		uint64 va = KSTACK((int) (p - procs));
		kvmmap(pg, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
	}
}


int wait(uint64 addr){
	struct proc *p = myproc();
	int havekids,pid;

	struct proc *np;

	acquire(&wait_lock);
	for(;;){
		havekids = 0;
		for(np = procs; np < &procs[NPROC]; np++){
			if(np->parent == p){
				acquire(&np->slock);
				havekids = 1;
				if(np->state == ZOMBIE){
					pid = np->pid;
					if(addr != 0 && copyoutpg(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {
						release(&np->slock);
						release(&wait_lock);
						panic("wait:copyoutpg -1");
						return -1;
					}
					freeproc(np);
					release(&np->slock);
					release(&wait_lock);
					return pid;
				}
				release(&np->slock);
			}
		}

		if(!havekids || p->killed){
			release(&wait_lock);	
			return -1;
		}
		sleep(p,&wait_lock);
	}
}



void sched(){
	struct proc *p = myproc();
	if(!holdinglock(&p->slock)){
		panic("sched holdinglock \n");
	}
	if(p->state == RUNNING){
		panic("sched p.state is Running \n");
	}
	if(intr_get()){
		panic("sched interruptible");
	}

	int intena = mycpu()->intena;
	swtch(&p->cont, &mycpu()->context);
	mycpu()->intena = intena;
}


void sleep(void *p,struct spinlock *lk){
	struct proc *pc = myproc();

	acquire(&pc->slock);
	release(lk);
	pc->chan = p;
	pc->state = SLEEPING;

	sched();

	pc->chan = 0;
	release(&pc->slock);
	acquire(lk);
}

void scheduler(){
	struct proc *p;
	struct cpu *c = mycpu();
	c->p = 0;
	for(;;){
		intr_on();
		for(p = procs; p < &procs[NPROC];p++){
			acquire(&p->slock);
			if(p->state == RUNNABLE){
				p->state = RUNNING;
				c->p = p;
				swtch(&c->context,&p->cont);
				c->p = 0;
			}
			release(&p->slock);
		}
	}
}


void yield(){
	struct proc *p = myproc();
	acquire(&p->slock);
	p->state = RUNNABLE;
	sched();
	release(&p->slock);
}

pagetable_t proc_pagetable(struct proc *p){
	pagetable_t pagetable;

	pagetable = uvmcreate();
	if(pagetable == 0){
		panic("proc_pagetable: uvmcreate");
	}
	if(mappages(pagetable, TRAMPOLINE, PGSIZE,(uint64)trampoline, PTE_R | PTE_X) < 0){
		panic("------proc_pagetable : trampoline");
		uvmfree(pagetable, 0);
    	return 0;
	}

	if(mappages(pagetable, TRAPFRAME, PGSIZE,(uint64)(p->trapframe), PTE_R | PTE_W) < 0){
		panic("------proc_pagetable : p->trapframe");
		uvmfree(pagetable, 0);
    	return 0;
	};
	return pagetable;
}

static struct proc* allocproc(){
	struct proc *p;

	for(p = procs; p < &procs[NPROC]; p++){
		acquire(&p->slock);
		if(p->state == UNUSED){
			p->pid = allocpid();
			p->state = USED;

			if((p->trapframe = (struct trapframe*)kalloc()) == 0){
				panic("alloc p->trapframe panic...\n");
				freeproc(p);
   				release(&p->slock);
				return 0;
			}

			p->pagetable = proc_pagetable(p);
			if(p->pagetable == 0){
				freeproc(p);
   				release(&p->slock);
				panic("alloproc proc_pagetable alloced panic");
				return 0;
			}
			memset(&p->cont,0,sizeof(p->cont));
			p->cont.ra = (uint64) forkret;
			p->cont.sp = p->kstack + PGSIZE;
			return p;
		}
		release(&p->slock);	
	}
	return 0;
}

void userinit(){
	struct proc *p = allocproc();
	initp = p;

	uvminit(p->pagetable, initcode, sizeof(initcode));
	p->sz = PGSIZE;

	p->trapframe->epc = 0;
	p->trapframe->sp = PGSIZE;
	
	safestrcpy(p->name,"initcode",sizeof(p->name));
	p->pwd = rooti();

	p->state = RUNNABLE;
	release(&p->slock);	
}

void reparent(struct proc *p){
	struct proc *pp;
	for(pp = procs; pp < &procs[NPROC];pp++){
		if(pp->parent == p){
			pp->parent = initp;
			wakeup(initp);
		}
	}
}

void exit(int n){
	struct proc *p = myproc();
	if(p == initp){
		panic("init proc exit");
	}
	for(int fd = 0;fd < OPENFILE;fd++){
		if(p->openfs[fd]){
			fileclose(p->openfs[fd]);
			p->openfs[fd] = 0;
		}
	}

	iput(p->pwd);
	p->pwd = 0;

	acquire(&wait_lock);

	reparent(p);
	wakeup(p->parent);

	acquire(&p->slock);
	p->xstate = n;
	p->state = ZOMBIE;
	
	release(&wait_lock);
	sched();
	panic("proc exit");
}

int fork(){
	struct proc *now = myproc();
	struct proc *p = allocproc();
	if(p == 0){
		return -1;
	}
	if(uvmcopy(now->pagetable,p->pagetable,now->sz) < 0){
		freeproc(p);
		release(&p->slock);
		return -1;
	}
	p->sz = now->sz;
	*(p->trapframe) = *(now->trapframe);

	p->trapframe->a0 = 0;
	for(int i = 0; i < OPENFILE; i++){
		if(now->openfs[i]){
			p->openfs[i] = filedup(now->openfs[i]);
		}
	}
	p->pwd = idup(now->pwd);

	safestrcpy(p->name,now->name,sizeof(now->name));
	int pid = p->pid;

	release(&p->slock);

	acquire(&wait_lock);
	p->parent = now;
	release(&wait_lock);

	acquire(&p->slock);
	p->state = RUNNABLE;
	release(&p->slock);
	return pid;
}
