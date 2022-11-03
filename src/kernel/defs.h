struct context;
struct spinlock;
struct buf;
struct superblock;
struct sleeplock;
struct file;
struct cpu;
struct proc;

// swtch.S
void swtch(struct context*, struct context*);

// spinlock.c
void acquire(struct spinlock*);
void release(struct spinlock*);
void initlock(struct spinlock*,char*);
void push_off();
void pop_off();
int holdinglock(struct spinlock*);

// syscall.c
void syscall();

// sleeplock.c
void sleep_lock(struct sleeplock*);
void sleep_unlock(struct sleeplock*);
void sleep_initlock(struct sleeplock*,char*);
int holdingsleep(struct sleeplock*);

// exec.c
int exec(char*,char**);

// argsuitl.c
int argaddr(int,uint64*);
int argstr(int,char*,int);
int argint(int,int*);

// proc.c
struct cpu* mycpu();
int cpuid();
struct proc* myproc();
int allocpid();
void scheduler();
void userinit();
int wait(uint64);
void sleep(void*,struct spinlock*);
void initproc();
void proc_mapstacks(pagetable_t);
void wakeup(void*);
void yield();
pagetable_t proc_pagetable(struct proc*);

// file.c
void init_filecache();
struct file* filealloc();
struct file* filedup(struct file*);

// memlayout.c
void uart_putstr(char*);
void uart_putc(char);
void uartinit();
int uartgetc();
void uartinterrupt();
char* getCmd();
int getShellResult();

// plic.c
int plic_claim();
void plicinit();
void plicinithart();
void complate_irq(int);

// trap.c
void trapinit();
void usertrapret();

// console.c
void consoleinit();

// fs.c
struct inode* rooti();
struct inode* iget(uint,uint);
struct buf* bread(uint,uint);
int readi(struct inode*,int,uint64,uint,uint);
struct inode* inodeByName(struct inode*,char*);
void iupdate(struct inode*);
struct inode* ialloc(uint,short);
int dirlink(struct inode*,char*,short);
int writei(struct inode*,int,uint64,uint,uint);
struct inode* iname(char*);
void initfs(int);
void init_bcache();
void brelease(struct buf*);
void init_inodecache();
void ilock(struct inode*);
struct inode* rootsub(char*);
void iunlockput(struct inode*);
void iunlock(struct inode*);
void iput(struct inode*);

// print.c
void printf(char*, ...);
void print(char*);
void println(char*);
void printP(uint64);
void printinit();
void panic(char*);

// virt.c
void virtio_disk_init();
void virt_disk_rw(struct buf*,int);
void virtio_disk_isr();

// spaceswap.c
uint copyout(int,uint64,void*,int);
int either_copy(void*,int,uint64,uint64);
int either_copyout(int,uint64,void*,uint64);


// uitl.c
char* memset(void*,int,int);
void* memmove(void*,void*,int);
int strncmp(const char*,const char*,int);
char* safestrcpy(char*,const char*,int);


// vm.c
void kfree(void*);
void freerange(void*,void*);
void kinit();
void* kalloc();
void kvmmap(pagetable_t,uint64, uint64, uint64, int);
int mappages(pagetable_t,uint64,uint64,uint64,int);
void uvminit(pagetable_t,uchar*,uint);
pagetable_t uvmcreate();
uint64 walkaddr(pagetable_t,uint64);
uint64 uvmalloc(pagetable_t,uint64,uint64);
uint64 uvmdealloc(pagetable_t,uint64,uint64);
void uvmunmap(pagetable_t,uint64,uint64,int);
void uvmclear(pagetable_t,uint64);
void proc_freepagetable(pagetable_t,uint64);
void freewalk(pagetable_t);
pte_t* walk(pagetable_t,uint64,int);

#define NELEM(x) (sizeof(x)/sizeof((x)[0]))