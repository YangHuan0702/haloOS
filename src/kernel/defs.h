struct context;

// swtch.S
void swtch(struct context *old, struct context *new);

// proc.c
int get_tasks();
void user_init();
void run_target_task_num(int num);
void run_os_task();

// memlayout.c
void uart_putstr(char* s);
void uart_putc(char c);



// print.c
void printf(char *s, ...);
void print(char *s);
void println(char *s);
void printP(uint64 ptr);

