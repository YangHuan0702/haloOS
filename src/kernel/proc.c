#include "type.h"
#include "defs.h"
#include "memlayout.h"
#include "file.h"
#include "spinlock.h"
#include "proc.h"
#include "riscv.h"

struct cpu cpus[NCPU];
struct spinlock pid_lock;
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

int allocpid(){
	int pid;
	lock(&pid_lock);
	pid = nextPid++;
	unlock(&pid_lock);
	return pid;
}
