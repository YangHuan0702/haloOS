struct context;

// swtch.S
void swtch(struct context *old, struct context *new);

// proc.c
void user_task0();

// memlayout.c
void uart_putstr(char* s);
void uart_putc(char c);


// print.c
void printf(char *s, ...);
void print(char *s);
void println(char *s);

