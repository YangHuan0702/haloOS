
// system call
int write(int,void*,int);
int open(char*,int);
int dup(int);
int mknod(char*,int,int);
int fork();
int exec(char*,char**);
int wait(int*);
int read(int,char*,int);

// printf.c
// void fprintf(int,char*,...);
// void println(char*);
void printf(char*,...);

// str.c
void* memset(void*,int,int);
int strlen(char*);