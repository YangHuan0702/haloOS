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
