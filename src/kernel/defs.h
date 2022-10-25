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
void lock(struct spinlock*);
void unlock(struct spinlock*);
void initlock(struct spinlock*,char*);
void push_off();
void pop_off();

// sleeplock.c
void sleep_lock(struct sleeplock*);
void sleep_unlock(struct sleeplock*);
void sleep_initlock(struct sleeplock*,char*);

// exec.c
int exec(char*,char**);

// argsuitl.c
void argaddr(int,uint64*);
int argstr(int,char*,int);
int argint(int,int*);

// proc.c
struct cpu* mycpu();
int cpuid();
struct proc* myproc();
int allocpid();
void scheduler();
void userinit();

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

// console.c
void consoleinit();

// fs.c
struct inode* rooti();
struct inode* iget(uint,uint);
struct buf* bread(uint,uint);
int readi(struct inode*,int,uint64,uint,uint);
struct inode* inodeByName(struct inode*,char*);
struct inode* create(char*,short,short,short);
void iupdate(struct inode*);
struct inode* ialloc(uint,short);
int dirlink(struct inode*,char*,short);
int writei(struct inode*,int,uint64,uint,uint);
struct inode* inodeByName(char*);
void initfs(int);
void init_bcache();
void init_inodecache();

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
void* copyout(void*,void*,int);
int either_copy(void*,int,uint64,uint64);
int either_copyout(int,uint64,void*,uint64);


// uitl.c
char* memset(void*,int,int);
void* memmove(void*,void*,int);
int strncmp(const char*,const char*,int);