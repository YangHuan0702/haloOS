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
		initlock(p->slock,"proc");
	}
}


int allocpid(){
	int pid;
	lock(&pid_lock);
	pid = nextPid++;
	unlock(&pid_lock);
	return pid;
}

void forkret(){
	static int firstinit = 1;

	unlock(&myproc()->slock);

	if(firstinit){
		firstinit = 0;
		fsinit(ROOTDEV);
	}
	// TODO
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



int wait(uint64 p){
	struct proc *p = myproc();
	int havekids,pid;

	struct proc *np;

	lock(&wait_lock);
	for(;;){
		havekids = 0;
		for(np = procs; np < procs[NPROC]; np++){
			if(np->parent == p){
				lock(&np->slock);
				havekids = 1;
				if(np->state == ZOMBIE){
					pid = np->pid;
					freeproc(np);
					unlock(&np->slock);
					unlock(&wait_lock);
					return pid;
				}
				unlock(&np->slock);
			}
		}

		if(!havekids || p->killed){
			unlock(&wait_lock);	
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
	struct proc *myproc = myproc();

	lock(&myproc->slock);
	unlock(lk);
	myproc->chan = p;
	myproc->state = SLEEPING;

	sched();

	myproc->chan = 0;
	unlock(&myproc->slock);
	lock(lk);
}



void scheduler(){
	struct proc *p;
	struct cpu *c = mycpu();

	c->p = 0;
	for(;;){
		intr_on();
		for(p = procs; p < &procs[NPROC];p++){
			lock(&p->slock);
			if(p->state == RUNNABLE){
				p->state = RUNNING;
				c.p = p;
				swtch(&c->context,&p->cont);
				c->p = 0;
			}
			unlock(&p->slock);
		}
	}
}


void userinit(){
	struct proc *p = allocproc();
	initp = p;

	p->trapframe->epc = 0;
	p->trapframe->sp = PGSIZE;
	strncmp(p->name,"initcode",sizeof(p->name));
	p->pwd = rooti();
	p->state = RUNNABLE;
}
