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

extern void forkret(void);

struct spinlock pid_lock;
struct spinlock wait_lock;
volatile int nextPid = 1;

int cpuid(){
	int cpuid = r_tp();
	return cpuid;
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
	}
	p->trapframe = 0;
	p->pid = 0;
	p->chan = 0;
	p->parent = 0;
	p->name[0] = 0;
	p->killed = 0;
	p->state = UNUSED;
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
	if(holdinglock(&p->slock)){
		panic("sched holdinglock \n");
	}
	if(p->state = RUNNING){
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
				printf("swtch proc name:%s ra:%p ,sp:%p , s0:%d , s11:%d\n",p->name,p->cont.ra,p->cont.sp,p->cont.s0,p->cont.s11);
				swtch(&c->context,&p->cont);
				c->p = 0;
			}
			release(&p->slock);
		}
	}
}

static struct proc* allocproc(){
	struct proc *p;

	for(p = procs; p < &procs[NPROC]; p++){
		acquire(&p->slock);
		if(p->state == UNUSED){
			goto found;
		}
		release(&p->slock);	
	}
	return 0;

found:
	p->pid = allocpid();
	p->state = USED;

	memset(&p->cont,0,sizeof(p->cont));
	p->cont.ra = (uint64) forkret;
	p->cont.sp = p->kstack + PGSIZE;
	return p;
}

void userinit(){
	struct proc *p = allocproc();
	initp = p;
	printf("first proc ra is: %p\n",p->cont.ra);
	// p->trapframe->epc = 0;
	// p->trapframe->sp = PGSIZE;
	safestrcpy(p->name,"initcode",sizeof(p->name));
	p->pwd = rooti();
	p->state = RUNNABLE;
	release(&p->slock);	
}


void forkret(void){
	printf("---------");
	static int firstinit = 1;
	panic("join forkret\n");
	release(&myproc()->slock);

	if(firstinit){
		firstinit = 0;
		initfs(ROOTDEV);
	}
	// TODO
}
