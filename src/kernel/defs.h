struct context;
struct spinlock;
struct buf;
struct superblock;

// swtch.S
void swtch(struct context*, struct context*);

// spinlock.c
void lock(struct spinlock*);
void unlock(struct spinlock*);
void initlock(struct spinlock*,char*);

// proc.c
int get_tasks();
void user_init();
void run_target_task_num(int);
void run_os_task();

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

// print.c
void printf(char*, ...);
void print(char*);
void println(char*);
void printP(uint64);
void printinit();

// virt.c
void virtio_disk_init();
void virt_disk_rw(struct buf*,int);
void virtio_disk_isr();


// uitl.c
char* memset(void*,int,int);